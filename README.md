# myFitness

## Abstract

myFitness is a fitness tracking application developed for CIS 350 (Introduction to Software Engineering). The app allows users to log and monitor their workouts over time. Users can select from a built-in library of exercises (e.g., squats, dumbbell curls) or define their own custom exercises (e.g., jumping jacks). For each workout session, users log the date, sets × reps performed, and weight used. A progress tab visualizes improvements over a selected time period — including metrics such as progressive overload (weight increases) and volume trends (sets/reps over time).

---

## Table of Contents

- [Team Members](#team-members)
- [Project Management](#project-management)
- [Features](#features)
- [Architectural Design](#architectural-design)
- [Use Case Diagrams](#use-case-diagrams)
- [Tech Stack](#tech-stack)
- [Setup & Installation](#setup--installation)

---

## Team Members

| Name |
|------|
| CK Thang  |
|Leah Linton|

---

## Project Management

Jira Board: *(link here)*

We use Jira to manage tasks, track progress, and organize our work into sprints. Each sprint contains a set of tickets representing individual tasks or features. As work begins on a ticket it is moved to **In Progress**, and marked **Done** upon completion. This gives us a clear picture of what's been accomplished and what still needs to be done at any point in the project.

**Project Checkpoint 1 Sprint (Jun 3 – Jun 5):**

![Jira Sprint 1](assets/jira.png)

---

## Features

- **User Authentication** — Secure login and account creation
- **Exercise Library** — Pre-loaded exercises (squats, dumbbell curls, bench press, etc.)
- **Custom Exercises** — Users can add their own exercises (e.g., jumping jacks)
- **Workout Logging** — Log date, sets × reps, and weight per exercise
- **Progress Tracking** — Visualize progress over a chosen time period
  - Progressive overload (weight lifted over time)
  - Volume trends (total sets/reps over time)

---

## Architectural Design

myFitness follows a client-serverless architecture. The Flutter mobile app communicates directly with Firebase services — there is no custom backend server.

- **Frontend:** Flutter (Dart) — cross-platform mobile app for iOS and Android
- **Auth:** Firebase Authentication — handles user registration, login, and session management
- **Database:** Firebase Firestore — NoSQL cloud database storing users, exercises, and workout logs
- **Hosting/Backend:** Firebase — no separate server required

---

## Use Case Diagrams

*(Use case diagrams to be added)*

Primary actors: **User**

Key use cases:
- Register / Login
- Browse exercise library
- Add custom exercise
- Log a workout session
- View progress over time

---

## Tech Stack

| Layer      | Technology              |
|------------|-------------------------|
| Frontend   | Flutter (Dart)          |
| Backend    | Firebase (serverless)   |
| Database   | Firebase Firestore      |
| Auth       | Firebase Authentication |

---

## Setup & Installation

*(To be completed once tech stack is finalized)*

```bash
# Clone the repository
git clone <repo-url>
cd fitness-tracker

# Install dependencies
# TBD

# Run the app
# TBD
```

---

*CIS 350 — Introduction to Software Engineering*
