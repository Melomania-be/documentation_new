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
      label: 'Technical Documentation',
      items: [
        'Technical Documentation/callsheet',
        'Technical Documentation/attendance',
        'Technical Documentation/files',
      ],
    },
  ],
};

export default sidebars;