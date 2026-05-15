# TD - Project Participants

So, in Melomania, a **Participant** is basically the link between a real person (a **Contact**) and a specific **Project**. 

If John is in the database as a Contact, he only becomes a Participant when he joins the "Summer Concert" project. This Participant model keeps track of his role in that specific project, like what section he plays in (like Violins or Flutes), if he's the section leader, and if his application is accepted or still pending. It also tracks his attendance for rehearsals and concerts.

---

## The Model (`Participant`)

You can find the model in `app/models/participant.ts`.

### Main Fields
Here are the most important columns we save in the database:
*   `id`: The primary key.
*   `project_id` & `contact_id`: These link the person to the project.
*   `section_id`: What instrument group they belong to.
*   `accepted` (boolean): This is super important. If it's `false`, the person is just an "applicant". If it's `true`, they are an official active participant.
*   `is_section_leader` (boolean): True if they are the boss of their section.
*   `audition_status`: Can be `none`, `pending`, or `completed`.

### Relationships
A Participant is connected to a lot of other things:
*   **BelongsTo**: They belong to a `Project`, a `Contact`, and a `Section`.
*   **HasMany**: They can have multiple `Auditions` and `Answers` (like when they fill out availability forms).
*   **ManyToMany (Pivot tables)**:
    *   `Rehearsals` and `Concerts`: These use pivot tables because a participant goes to many events, and an event has many participants. The cool thing is we added a `comment` column in the pivot table to track things like "Was late" or "Sick".
    *   `Callsheets`: To track if they have seen the schedule.

---

## The Controller (`ParticipantsController`)

The controller (`app/controllers/participants_controller.ts`) basically handles two main things: people applying (Applications) and people who are already in (Active Participants).

### 1. Handling Applications
When someone applies, they are created as a Participant but with `accepted: false`.
*   `getApplications(ctx)`: This fetches everyone who isn't accepted yet. It loads a bunch of data like their form answers and audition files so the admins can review them.
*   `validateParticipant(ctx)`: This is called when an admin clicks "Accept". It changes `accepted` to `true`. Also, behind the scenes, it talks to the Recruitment module to mark this person as "recruited" so HR knows they are in!

### 2. Handling Active Participants
*   `getAll(ctx)`: Fetches all the `accepted: true` participants for a project. We use `simpleFilter` here so the user can easily search them by name, email, or section.
*   `getOne(ctx)`: Just gets the details of one participant.
*   `getParticipantsCountBySection(ctx)`: This is a really handy method used for the Dashboard. It just groups and counts participants by section (e.g., 5 Violins, 3 Cellos).

### 3. Creating and Updating (`createOrUpdate`)
This is the biggest function. It does a few important things:
*   It makes sure we don't accidentally add the same contact twice to the same project.
*   It deletes and recreates the form answers so they are always up to date.
*   **Attendance**: When updating rehearsals or concerts, it uses `.sync()` to update the pivot tables, making sure to save the `pivot_comment` (like absence reasons) along the way.

### 4. Deleting (`delete`)
If we remove a participant from a project, we have to clean up:
*   First, we tell the Recruitment module to change their status to 'cancelled'.
*   Then, we use `.detach()` to remove their connections to concerts and rehearsals in the pivot tables so we don't leave floating data behind. Finally, we delete the participant record itself.

---

## Things to watch out for!

*   **Don't forget the pivot columns!** If you write a new query fetching a participant's concerts or rehearsals, you MUST include `.pivotColumns(['comment'])`. If you don't, the app won't know if the person was absent or late because it won't load the comment from the pivot table.
*   **Participant vs RecruitmentContact**: Keep in mind that a Participant handles the musical/event side (playing in concerts), while `RecruitmentContact` handles the admin side (how we contacted them, if they accepted). The controller takes care of keeping them synced when you validate or delete someone.
