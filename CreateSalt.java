import java.security.SecureRandom;

/**
 * Creates a long, secure salt that can be safely represented as a
 * string. Intented to be run from the command line. Optional argument
 * specifies the number of bytes to use for the salt.
 *
 * Salt is created by generated a random number of bytes, then taking
 * the SHA-512 hash to generate a simple hex string.
 */
public class CreateSalt {

    private static final int DEFAULT_LENGTH = 128;

    public static void main(String[] args) throws Exception {
        int length;
        if (args.length == 1) {
            length = Integer.valueOf(args[0]);
        } else {
            length = DEFAULT_LENGTH;
        }

        SecureRandom random = new SecureRandom();

        byte[] salt = new byte[512];
        random.nextBytes(salt);
        HashGenerator generator = new HashGenerator(String.valueOf(salt));

        byte[] bytes = new byte[length];
        random.nextBytes(bytes);
        System.out.println(generator.hash(bytes));
    }
}
