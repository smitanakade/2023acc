/**
 * @description IdFaker enables using generated IDs in
 * unit tests.
 *
 * This is useful to test logic based on Ids or lookup fields
 * without having to insert records in the DB first.
 */
@IsTest
public class IdFaker {
    private static Long idCount = 1;

    /**
     * @description generates a fake ID for the given
     * object type.
     *
     * The generated Id uniqueness is guaranted within the
     * same transaction only.
     *
     * @param soType the SObjectType to generate an ID for.
     * @return a fake, but valid, Id for the given type.
     */
    public static Id generateFor(SObjectType soType) {
        final String typePrefix = soType.getDescribe().getKeyPrefix();
        // Get environment-specific ID element from user ID
        final String envPrefix = UserInfo.getUserId().substring(3, 6);

        final String uniqueId = String.valueOf(idCount).leftPad(9, '0');

        idCount++;

        return Id.valueOf(typePrefix + envPrefix + uniqueId);
    }
}