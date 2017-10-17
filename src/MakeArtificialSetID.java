import java.io.*;
import java.util.StringTokenizer;


/**
 *
 *
 * @author Brent Davis
 *
 * This is a class which will take as input a .BIM file (from a vcf or otherwise) and use it
 * to construct a 'fake' SetID file to be used in getting the SKAT R package to run.
 *
 * The BIM file has a list of genes. The program will take as input 1) the bim file, and
 * 2) the number of genes to group together into a 'gene'.
 *
 * The set ID is a tab delimited file with no headers.
 *
 *
 *
 *
 */

public class MakeArtificialSetID {

	/**
	 *
	 * @param args
	 * This program expects the args 0 to be the filename to be opened, and the args 1 to be the number of
	 * variants to group into a single gene.
	 */

	public static void main(String args[]){
	try{

		FileInputStream fis = new FileInputStream(args[0]);
		File fout = new File(args[0]+".SetID");
		FileOutputStream fos = new FileOutputStream(fout);
		int geneSplit = Integer.parseInt(args[1]);

		//Construct BufferedReader from InputStreamReader
		BufferedReader br = new BufferedReader(new InputStreamReader(fis));

		BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(fos));

		//Used to initialize the line to be examined.
		String line = null;

		//The EPACTS group file is tab delimited so we need to use a tab here.
		String delims = "	";


		int counter = 0;
		// This line cycles through the lines one by one. It'll make sure we process the entire text file.
					while ((line = br.readLine()) != null) {

						//System.out.println("Processing");

						// The string tokenizer actually breaks up the thing to be processed into chunks.
						StringTokenizer st = new StringTokenizer(line,delims);
						// This gets us the SNP part of the line.
						String snpLine = st.nextToken();
						snpLine = st.nextToken();

						bw.write("Gene" +counter/geneSplit + "	" + snpLine);
						bw.newLine();

						counter++;

						//System.out.println(line);
					}

					// Close the file reader and writer. We're done.
					br.close();
					bw.close();


	} catch (FileNotFoundException e){

		System.out.println("Did not find the file. " + e);

	} catch (IOException e) {
		e.printStackTrace();
	}


	}




}
