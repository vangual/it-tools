import { ArrowsShuffle } from '@vicons/tabler';
import { defineTool } from '../tool';

export const tool = defineTool({
  name: 'Favorites import export',
  path: '/favorites-import-export',
  description: '',
  keywords: ['favorites', 'import', 'export'],
  component: () => import('./favorites-import-export.vue'),
  icon: ArrowsShuffle,
  createdAt: new Date('2025-03-09'),
});