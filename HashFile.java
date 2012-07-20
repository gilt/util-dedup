import java.io.File;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.io.FileInputStream;
import java.io.BufferedReader;

/**
 * Class to help support process of hashing email addresses in
 * preparation for a safe deduplication. Basic idea is that we have
 * two companies (A and B) that would like to compare their list of
 * user email addresses to figure out which ones appear on the lists
 * from both companies.
 *
 * Idea is that each company:
 *
 *   1. Generates a text file containing all their email addresses
 *
 *   2. Invokes this program to create a new file containing the
 *      hashes of all their email addresses
 *
 *   3. Files are then compared in any separate process to figure out
 *      which hashes are the same (appear in both companies) and which
 *      are different.
 *
 * From there, a separate program can then rehash all of the passwords
 * to find the actual email addresses that we want to use.
 */
public class HashFile {

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.out.println(usage());
            System.exit(1);
        }

        String salt = Salt.read(args[0]);
        String path = args[1];

        HashGenerator generator = new HashGenerator(salt);
        FileWrapper fileWrapper = new FileWrapper(generator, new File(path));
        fileWrapper.process();
    }

    private static String usage() {
        StringBuilder sb = new StringBuilder();
        sb.append("USAGE:\n");
        sb.append("  java HashFile <saltPath> <dataPath>\n");
        sb.append("    saltPath: The path to file containing the salt to use for hashing\n");
        sb.append("    dataPath: Path to the file whose contents we would like to hash. We read \n");
        sb.append("              from the file, strip white space and lowercase the content, then \n");
        sb.append("              output a hash of the value line for line to STDOUT\n");
        sb.append("\nEXAMPLE:\n");
        sb.append("  java HashFile salt.txt test.txt > hashed.txt\n");
        return sb.toString();
    }

    private static class FileWrapper {

        private final File file;
        private final HashGenerator generator;

        public FileWrapper(HashGenerator generator, File file) {
            this.generator = generator;

            if (!file.exists()) {
                throw new RuntimeException("File[" + file + "] could not be found");
            }
            this.file = file;
        }

        public void process() throws Exception {
            DataInputStream in = null;
            try {
                in = new DataInputStream(new FileInputStream(file));
                BufferedReader br = new BufferedReader(new InputStreamReader(in));
                String line, lowerCaseTrimmedLine;
                while ((line = br.readLine()) != null)   {
                    lowerCaseTrimmedLine = line.toLowerCase().trim();
                    System.out.println(generator.hash(lowerCaseTrimmedLine));
                }
            } finally {
                in.close();
            }
        }
    }
}
