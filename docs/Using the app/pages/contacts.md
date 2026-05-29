# Contacts pages
## Main contacts page
![Main contacts page](/img/using_the_app/contacts_main.png)
This page just serves as a gateway to all the features involving contacts management.

## Contacts search
![Contacts search page](/img/using_the_app/contacts_search.png)
This page features the main contacts database search engine. As shown on the screenshot, it shows contacts with their instrument(s) and corresponding levels (one can be excellent in an instrument and a beginner in another), some contacts info and a comment. The search engine can filter contacts by instrument, instrument family, level, project played, or any other field, or any combination of those fields to allow complex searches.
<div style={{ display: 'flex', gap: '5px', justifyContent: 'center' }}>
  <img src="/img/using_the_app/contacts_search_filter1.png" width="33%" />
  <img src="/img/using_the_app/contacts_search_filter2.png" width="33%" />
  <img src="/img/using_the_app/contacts_search_filter3.png" width="33%" />
</div>
Clicking on the arrow at the right side of a contact line displays the contact details page, with all details pertianing to that contact.

## Contact details page
![Contact details page](/img/using_the_app/contacts_details1.png)
![Contact details page](/img/using_the_app/contacts_details2.png)
![Contact details page](/img/using_the_app/contacts_details3.png)
This page displays all the data stored about a person. At the top, it show the contact data (mail, phone, Messenger handle), comments, instruments and levels and date of creation and last update. Below that, it shows all the projects the contact has participated in, and the section they played in. At the bottom of the page, it shows if the person has received (or is still owed for an ongoing or recent project) a payment. This is linked to the accounting page of the pertinent project. The contact can be edited or deleted by clicking on the button in the top right corner.

## Contact creation page
![Contact creation page](/img/using_the_app/contacts_creation.png)
This page is pretty self-explanatory and allow to create a contact by filling out all the basic fields. To retroactively indicate that the contact has played in a project, it needs to be manually added to the participants list of said project through the project management page.

## Contacts lists
Contacts lists are used to write an email to a custom group of people. The app can send an email to all participants of a project without needing to create a list, but if the user needs to send an email to a subgroup of the project (all strings, for instance), or outside the scope of one specific project, they need to make a list. There are three pages for lists: a main page with all the lists, a list creation page and a list details page.

### Main lists page
![Contact lists page](/img/using_the_app/contacts_lists.png)
This page serves as the dashboard for all custom contact lists and mailing groups. It has been fully updated to align with the database design system, featuring the premium ModuleHeader card and consistent table layout. 

The main table displays all existing lists with:
- **ID:** The unique list identifier.
- **Name:** The custom name of the list.
- **Contacts:** A preview of all the member names grouped in that list.
- **Actions:** The navigation arrow on the right leads directly to the **List details and modification page**.

### List details and modification page
This page shows the details of a single list, including its name, creation/update timestamps, and the members currently in the list.

It allows you to:
- **Change the List Name:** Modify the list name directly at the top.
- **View Selected Contacts:** Review the members in a clean table layout listing their names, emails, and instruments.
- **Remove Contacts:** Click the red trash button to remove a contact from the list.
- **Save or Delete:** Commit your changes by clicking **Save**, or delete the entire list by clicking **Delete**.

### List creation page
This page lets you create a new contact list from scratch.

To build your list:
1. **Set a List Name:** Fill in the list name input field.
2. **Search and Filter Contacts:** Use the **Advanced Query Builder** at the bottom of the page to filter your database contacts by instrument, project, or section.
3. **Select Members:** Check the boxes next to the contacts you wish to add, then click **Add to List**.
4. **Save the List:** Click **Save** in the top right to store the newly created list in the database.