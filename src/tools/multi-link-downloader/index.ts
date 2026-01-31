import { IconFileDownload } from '@tabler/icons-vue';
import { defineTool } from '../tool';

export const tool = defineTool({
  name: 'Multi link downloader',
  path: '/multi-link-downloader',
  description: 'The tool will asynchronously combine the contents of the provided links into a single zip file for you to download. (Requires an internet connection)',
  keywords: ['multi', 'link', 'downloader'],
  component: () => import('./multi-link-downloader.vue'),
  icon: IconFileDownload,
  createdAt: new Date('2024-10-18'),
  category: 'Network',
  externAccessDescription: t('tools.multi-link-downloader.externalAccess'),
});
