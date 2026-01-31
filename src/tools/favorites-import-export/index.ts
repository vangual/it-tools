import { CompareArrowsRound } from '@vicons/material';
import { defineTool } from '../tool';
import { translate } from '@/plugins/i18n.plugin';

export const tool = defineTool({
  name: translate('tools.favorites-import-export.title'),
  path: '/favorites-import-export',
  description: translate('tools.favorites-import-export.description'),
  keywords: ['favorites', 'import', 'export'],
  component: () => import('./favorites-import-export.vue'),
  icon: CompareArrowsRound,
  createdAt: new Date('2025-03-09'),
});
