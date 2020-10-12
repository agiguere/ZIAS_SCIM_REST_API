# SCIM REST API for ABAP
SAP Identity Authentication Services SCIM REST API for ABAP

The System for Cross-domain Identity Management (SCIM) REST API allows to manage IAS users & groups.

This repo expose the SCIM REST API through a simple ABAP class, so you can create create IAS users & groups from an ABAP Netweaver System like SAP CUA or SAP ERP / HANA.

## Backend Compatbility

Any SAP Business Suite systems (ERP, HCM, SRM ...) runnning SAP NetWeaver 740 or higher.

## Prerequisites

Create a system as administrator with an assigned Manage Users role.

## Installation & Configuration Steps

### Step 1 - Create and configure an RFC destination

Create an RFC destination of type G in transaction SM59

Named it `SCIM_REST_API` as an example or whatever you prefer.

Under the tab `Technical Settings` enter the target host of your IAS tenant, the URL pattern should look something like

```
https://<tenant ID>.accounts.ondemand.com/
```

for the port, enter `443` and the path prefix is `/restnotification`.

Under the `Logon & Security` tab, select basic authentication and enter the credential of the system administrator created previously.

To conclude, click SSL active at the bottom and make sure the SSL certificate is set to `DFAULT SSL Client (Starndard)`.


## API Documentation


ABAP Interface ZIF_IAS_USER_API

| Method       | Description                     | API Doc                                                                                                                                |
| ------------ | ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| GET_USER     | Get information on a known user | [User Resource](https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/7ae17a6da5314246a04d113f902d0fdf.html)        |
| CREATE_USER  | Create a user                   | [Create User Resource](https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/cea87780bee94c6994b8005c6d6a4815.html) |
| DELETE_USER  | Delete an existing user         | [Delete User Resource](https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/436015d66dad4c129a87604eda2f7134.html) |
| SEARCH_USERS | Users search                    | [Users Search](https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/3af7dfae0aad4cf79ab8d822f8322e76.html)         |
| UPDATE_USER  | Update a known user             | [Update User Resource](https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/9e36479e92ca4b0db75f085d4ab3aa23.html) |


ABAP Interface ZIF_IAS_GROUP_API

| Method                 | Description                                            | API                                                                                                                                     |
| ---------------------- | ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- |
| CREATE_GROUP           | Create a user group                                    | [Create Group Resource](https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/8c6ebd7c1c564d8e9eb4fa404641d6e7.html) |
| DELETE_GROUP           | Delete an existing group                               | [Delete Group(https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/41bb51961c274db18c82cc4182025a42.html) Resource] |
| GET_GROUP              | Get information on a known group                       | [Group Resource]                                                                                                                        |
| SEARCH_GROUPS          | Groups search                                          | [Groups Search]                                                                                                                         |
| UPDATE_GROUP           | Update an existing group                               | [Update Group Resource](https://help.sap.com/viewer/6d6d63354d1242d185ab4830fc04feb1/Cloud/en-US/81ca50e7e604474fa9ce53c831156cd2.html) |
| SERIALIZE_CREATE_GROUP | Encode ABAP structure to JSON for the create group API |                                                                                                                                         |
| SERIALIZE_UPDATE_GROUP | Encode ABAP structure to JSON for the update group API |                                                                                                                                         |
| DESERIALIZE_GROUP      | Parse JSON response to an ABAP structure               |                                                                                                                                         |
| DESERIALIZE_GROUPS     | Parse JSON response to an ABAP internal table          |                                                                                                                                         |

ABAP Class ZCL_IAS_SCIM_REST_API

| Method           | Description                                       |
| ---------------- | ------------------------------------------------- |
| GET_INSTANCE     | Create HTTP connection and return object instance |
| CLOSE_CONNECTION | Close HTTP connection                             |

| Interaces         | Description |
| ----------------- | ----------- |
| ZIF_IAS_GROUP_API | Group API   |
| ZIF_IAS_USER_API  | User API    |