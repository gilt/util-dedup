import java.security.SecureRandom;

/**
 * Creates a long, secure salt that can be safely represented as a
 * string.
 */
public class CreateSalt {

    public static void main(String[] args) throws Exception {
        int length;
        if (args.length == 1) {
            length = Integer.valueOf(args[0]);
        } else {
            length = 128;
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
