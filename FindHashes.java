import java.util.Set;
import java.util.HashSet;

import java.io.File;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.io.FileInputStream;
import java.io.BufferedReader;

/**
 * Given a salt, an input file of hashes, and an input file of actual
 * data (e.g. email addresses), will run through the actual data and
 * print out all lines that exist in the file of hashes.
 */
public class FindHashes {

    public static void main(String[] args) throws Exception {
        if (args.length != 3) {
            System.out.println(usage());
            System.exit(1);
        }

        String salt = Salt.read(args[0]);
        String dataPath = args[1];
        String hashPath = args[2];

        Set<String> allHashes = readIntoSet(new File(hashPath));

        HashGenerator generator = new HashGenerator(salt);
        FileHashFinder finder = new FileHashFinder(generator, allHashes, new File(dataPath));
        finder.process();
    }

    private static String usage() {
        StringBuilder sb = new StringBuilder();
        sb.append("USAGE:\n");
        sb.append("  java FindHashes <saltPath> <dataPath> <hashPath>\n");
        sb.append("    saltPath: The path to file containing the salt to use for hashing\n");
        sb.append("    dataPath: Path to the file containing all source data (e.g. email addresses)\n");
        sb.append("    hashPath: Path to the file containing all the hashes we are looking for\n");
        sb.append("\nEXAMPLE:\n");
        sb.append("  java FindHashes salt.txt emails.txt hashed-emails.txt\n");
        return sb.toString();
    }

    private static Set<String> readIntoSet(File file) throws Exception {
        if (!file.exists()) {
            throw new RuntimeException("File[" + file + "] could not be found");
        }

        Set<String> hashes = new HashSet<String>();

        DataInputStream in = null;
        try {
            in = new DataInputStream(new FileInputStream(file));
            BufferedReader br = new BufferedReader(new InputStreamReader(in));
            String line, lowerCaseTrimmedLine;
            while ((line = br.readLine()) != null)   {
                lowerCaseTrimmedLine = line.toLowerCase().trim();
                if (lowerCaseTrimmedLine.length() > 0) {
                    hashes.add(lowerCaseTrimmedLine);
                }
            }
        } finally {
            in.close();
        }

        return hashes;
    }

    private static class FileHashFinder {

        private final HashGenerator generator;
        private final Set<String> allHashes;
        private final File file;

        public FileHashFinder(HashGenerator generator, Set<String> allHashes, File file) {
            this.generator = generator;
            this.allHashes = allHashes;

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
                    String hash = generator.hash(lowerCaseTrimmedLine);
                    if (allHashes.contains(hash)) {
                        System.out.println(line);
                    }
                }
            } finally {
                in.close();
            }
        }
    }
}
