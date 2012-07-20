import java.io.File;
import java.io.DataInputStream;
import java.io.InputStreamReader;
import java.io.FileInputStream;
import java.io.BufferedReader;

/**
 * Utility class to read salt from a file and expose it as a string.
 */
public class Salt {

    private Salt() {}

    public static String read(String path) throws Exception {
        File file = new File(path);
        if (!file.exists()) {
            throw new RuntimeException("File[" + file + "] could not be found");
        }

        String salt = null;
        DataInputStream in = null;
        try {
            in = new DataInputStream(new FileInputStream(file));
            BufferedReader br = new BufferedReader(new InputStreamReader(in));
            String line, lowerCaseTrimmedLine;
            while ((line = br.readLine()) != null)   {
                if (salt == null) {
                    salt = line.toLowerCase().trim();
                } else {
                    throw new RuntimeException("Salt file[" + path + "] cannot contain more than 1 line of data");
                }
            }
        } finally {
            in.close();
        }

        if (salt == null) {
            throw new RuntimeException("Salt file[" + path + "] did not contain any data");
        }

        return salt;
    }
}
