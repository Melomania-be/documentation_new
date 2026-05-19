// @ts-check

/**
 * @type {import('@docusaurus/plugin-content-docs').SidebarsConfig}
 */
const sidebars = {
  tutorialSidebar: [
    'intro',
    {
      type: 'category',
      label: 'Using the app',
      items: [
        'Using the app/overview',
        {
          type: 'category',
          label: 'Pages',
          items: [
            'Using the app/pages/projects',
            {
              type: 'category',
              label: 'Project management pages',
              items: [
                'Using the app/pages/project management pages/project_dashboard',
                'Using the app/pages/project management pages/participants_view',
                'Using the app/pages/project management pages/project_mailing',
                'Using the app/pages/project management pages/attendance',
                'Using the app/pages/project management pages/callsheet_pages',
                'Using the app/pages/project management pages/accounting',
                'Using the app/pages/project management pages/recruitment',
                'Using the app/pages/project management pages/auditions',
              ],
            },
            'Using the app/pages/contacts',
            'Using the app/pages/users',
            'Using the app/pages/mailing',
            'Using the app/pages/sections_instruments',
            'Using the app/pages/files',
          ],
        },
      ],
    },
    'working on the app',
    'database',
    'workflows',
    {
      type: 'category',
      label: 'Technical documentation',
      items: [
        'Technical documentation/contacts',
        'Technical documentation/callsheet',
        'Technical documentation/attendance',
        'Technical documentation/files',
        'Technical documentation/sections_instruments',
        'Technical documentation/auditions',
        'Technical documentation/usersmanagement',
        'Technical documentation/composers_and_pieces',
        'Technical documentation/mailing',
        'Technical documentation/project_participants',
        'Technical documentation/recruitment',
        'Technical documentation/accounting',
      ],
    },
  ],
};

export default sidebars;