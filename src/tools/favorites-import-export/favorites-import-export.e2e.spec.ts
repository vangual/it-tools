import { test, expect } from '@playwright/test';

test.describe('Tool - Favorites import export', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/favorites-import-export');
  });

  test('Has correct title', async ({ page }) => {
    await expect(page).toHaveTitle('Favorites import export - IT Tools');
  });

  test('', async ({ page }) => {

  });
});