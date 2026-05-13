// @ts-check

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.

 @type {import('@docusaurus/plugin-content-docs').SidebarsConfig}
 */
const sidebars = {
  // By default, Docusaurus generates a sidebar from the docs folder structure
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
          ],
        },
      ],
    },
    {
      type: 'category',
      label: 'Technical Documentation',
      items: [
        'technical-documentation/contacts',
      ],
    },
    'working on the app',
    'database',
    'workflows',
  ],

  // But you can create a sidebar manually
  /*
  tutorialSidebar: [
    'intro',
    'hello',
    {
      type: 'category',
      label: 'Tutorial',
      items: ['tutorial-basics/create-a-document'],
    },
  ],
   */
};

export default sidebars;
