@IsTest
public without sharing class TestUserBuilder {
	private User m_user;
	private Id m_profileId;
	private Contact m_portalContact;
	private Boolean m_doInsert = false;
	private List<PermissionSet> m_permissionSets;
	private PermissionSetGroup m_permissionSetGroup;
	private List<PermissionSetLicense> m_permissionSetLicenses;

	public TestUserBuilder() {
	}

	public void setUserProfile(Id profileId) {
		this.m_profileId = profileId;
	}

	public void setPortalUser() {
		this.m_portalContact = new Contact(
			FirstName = 'test',
			LastName = 'Test',
			Salutation = 'Madam',
			Birthdate = Date.today().addYears(-20),
			AccountId = [SELECT Id FROM Account LIMIT 1]
			.Id
		);
	}
	public void setPortalUser(Id accountId) {
		this.m_portalContact = new Contact(
			FirstName = 'test',
			LastName = 'Test',
			Birthdate = Date.today().addYears(-20),
			AccountId = accountId
		);
	}

	public void setDoInsert(Boolean doInsert) {
		this.m_doInsert = doInsert;
	}

	public void setPermissionSets(List<PermissionSet> permissionSets) {
		this.m_permissionSets = permissionSets;
	}
	public void setPermissionSetGroup(PermissionSetGroup permissionSetGroup) {
		this.m_permissionSetGroup = permissionSetGroup;
	}

	public void setPermissionSetLicenses(
		List<PermissionSetLicense> permissionSetLicenses
	) {
		this.m_permissionSetLicenses = permissionSetLicenses;
	}

	public User createUser() {
		this.m_user = new User(
			ProfileId = this.m_profileId,
			Alias = 'standt',
			Email = 'standarduser@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = getUniqueUserName()
		);

		if (this.m_doInsert) {
			insertUser();
		}

		if (this.m_permissionSets != null && this.m_permissionSets.size() > 0) {
			tryInsertUser();
			this.applyPermissionSets();
		}

		if (
			this.m_permissionSetLicenses != null &&
			this.m_permissionSetLicenses.size() > 0
		) {
			tryInsertUser();
			this.applyPermissionSetLicenses();
		}
		return this.m_user;
	}

	private void tryInsertUser() {
		if (this.m_user.Id == null) {
			insertUser();
		}
	}

	private void applyPermissionSets() {
		// cannot apply permission sets without user Id
		// runAs avoids Mixed DML
		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
			for (PermissionSet permissionSet : this.m_permissionSets) {
				PermissionSetAssignment psa = new PermissionSetAssignment(
					PermissionSetId = permissionSet.Id,
					AssigneeId = this.m_user.Id
				);
				permissionSetAssignments.add(psa);
			}
			insert permissionSetAssignments;
		}
	}

	private void applyPermissionSetLicenses() {
		// cannot apply permission sets without user Id
		// runAs avoids Mixed DML
		System.runAs(new User(Id = UserInfo.getUserId())) {
			List<PermissionSetLicenseAssign> permissionSetLicenseAssigns = new List<PermissionSetLicenseAssign>();
			for (
				PermissionSetLicense permissionSetLicense : this.m_permissionSetLicenses
			) {
				PermissionSetLicenseAssign psl = new PermissionSetLicenseAssign(
					PermissionSetLicenseId = permissionSetLicense.Id,
					AssigneeId = this.m_user.Id
				);
				permissionSetLicenseAssigns.add(psl);
			}
			insert permissionSetLicenseAssigns;
		}
	}

	private static String getUniqueUserName() {
		return 'user' + DateTime.now().getTime() + '@doh_testorg.com.au';
	}

	private static Id getRoleId() {
		Id roleId = userInfo.getUserRoleId();
		if (roleId != null) {
			roleId = [SELECT Id FROM UserRole WHERE Name = 'Health Staff' LIMIT 1].Id;
		}
		return roleId;
	}

	private User m_portalUserCreator;
	private User getPortalUserCreator() {
		if (this.m_portalUserCreator == null) {
			this.m_portalUserCreator = new User(
				ProfileId = [
					SELECT Id
					FROM Profile
					WHERE Name = 'System Administrator'
					LIMIT 1
				]
				.Id,
				Alias = 'sysadt',
				Email = 'adminuser@testorg.com',
				EmailEncodingKey = 'UTF-8',
				LastName = 'TestAdmin',
				LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US',
				TimeZoneSidKey = 'Australia/Sydney',
				UserName = getUniqueUserName(),
				UserRoleId = getRoleId()
			);
			System.runAs(new User(Id = UserInfo.getUserId())) {
				insert this.m_portalUserCreator;
				List<PermissionSet> permissionSets = [
					SELECT Id
					FROM PermissionSet
					WHERE
						Name IN (
							'QFR_Create_Update_View',
							'System_Admin',
							'GPMS_Package_Permission_Set'
						)
				];
				System.runAs(new User(Id = UserInfo.getUserId())) {
					List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
					for (PermissionSet permissionSet : permissionSets) {
						PermissionSetAssignment psa = new PermissionSetAssignment(
							PermissionSetId = permissionSet.Id,
							AssigneeId = this.m_portalUserCreator.Id
						);
						permissionSetAssignments.add(psa);
					}
					insert permissionSetAssignments;
				}
			}
		}
		return this.m_portalUserCreator;
	}

	private User insertUser() {
		User u = this.getPortalUserCreator();
		System.runAs(u) {
			if (this.m_portalContact != null) {
				insert this.m_portalContact;
				// ensures owner of account is always an admin user with a UserRole - ensures portal user creation is valid
				update new Account(Id = this.m_portalContact.AccountId, OwnerId = u.Id);
				this.m_user.contactId = m_portalContact.Id;
			}
			insert this.m_user;
			System.assertNotEquals(null, this.m_user.Id);
		}
		return this.m_user;
	}
}
