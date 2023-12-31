/**
 * @description Feature Implementation that is always enabled
 */
public with sharing class AlwaysDisabledFeature implements Feature {
	/**
	 * @description returns false for all features
	 *
	 * @param featureName
	 * @return true
	 */
	public Boolean isEnabled(String featureName) {
		return false;
	}
}
