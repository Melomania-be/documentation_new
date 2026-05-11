# Global mailing manager
*Edited by Borshon*
The global mailing page is the app-wide email hub, separate from the project-level mailing tools. It is divided into three tabs: sending an email to a contact list, managing custom templates, and configuring system templates.

## Sending an email
![Sending an email](/img/using_the_app/mailing_send.png)

This tab is used to send emails outside the scope of a single project, targeting a custom contact list. On the right side of the screen, the user picks the contact list they want to reach. Once a list is selected, they can either write the email from scratch directly in the editor, or pick an existing template to use as a base.

When a template is selected, the app may ask for some extra information depending on what the template needs, for example a project name or specific contact details, so it can fill in the right values. Before anything is sent, a full preview of the final email is shown so the user can check everything looks correct. 

## Custom templates
![Custom templates](/img/using_the_app/mailing_templates.png)

This tab is where the user manages their own reusable email templates. Templates can be created, edited or deleted from here. The built-in visual editor lets the user format text, insert images, add links and structure the content without writing HTML by hand, though switching to HTML mode is also possible for more control.

Once a template is saved, it shows up in the list when the user goes to send an email, and they can select it from there. The user can also mark one template as the default, which will be pre-selected automatically when opening the send tab.

## System templates
![System templates](/img/using_the_app/mailing_system.png)

System templates are the automated emails the app sends out on its own during certain actions. This covers things like callsheet update notifications, recruitment emails sent to contacts, audition request emails and registration confirmation messages. These templates cannot be deleted since the app depends on them to work, but their content can be edited freely.

One important thing to keep in mind when editing system templates: they contain variables like `${NAME}`, `${PROJECT}`, `${CALLSHEET}`, or `${REGISTRATION}` that the app replaces with the real values at the moment the email is sent. These variables need to stay in the template exactly as they are. Removing or changing them will cause the app to send out emails with missing or broken information.
