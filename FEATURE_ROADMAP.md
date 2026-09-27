# Student Life Hub Feature Roadmap

This roadmap adds the requested improvements without replacing the current
offline-first data or breaking existing pages.

## Phase 1: Offline Productivity

1. Smart reminders for tasks, classes, exams, and events.
2. Recurring tasks for weekly assignments and habits.
3. Calendar view for daily, weekly, and monthly planning.
4. [x] Course grade tracker with GPA calculation.
5. [x] Pomodoro focus timer with study sessions.
6. Study goals and habit tracking.
7. Advanced search, filters, labels, and saved views.
8. Budget limits and spending alerts.
9. Attendance tracking for classes.
10. File attachments for notes and study documents.

## Phase 2: Offline Privacy and Sharing

11. App lock using a PIN or device authentication.
12. Encrypted local backups and safer export handling.
13. CSV and PDF report improvements.
14. English and Khmer localization.
15. Accessibility improvements, including screen-reader labels, contrast, and
    large-text layouts.

## Offline-Only Replacements

The application will not require internet access, an account, or a backend.

16. Local notifications for tasks, classes, exams, and events.
17. Local calendar views and calendar export files.
18. Encrypted local backup files stored or shared by the user.
19. Local study groups using exported schedules, tasks, or reports.
20. Optional local diagnostics that never upload personal records.

## Implementation Rules

- Keep the current JSON backup format compatible.
- Keep local mode working without an account or network connection.
- Add one repository and controller boundary per new feature.
- Add empty states and validation before adding advanced UI.
- Test each feature on a narrow mobile layout and a wide web layout.
- Do not add cloud services, authentication, or network calls. The app must
  remain useful with Wi-Fi and mobile data disabled.

## Recommended Order

The next implementation batch should be recurring tasks, local reminders,
attendance tracking, habit goals, budget alerts, app lock, and file
attachments. These provide immediate student value without requiring a
network connection.
