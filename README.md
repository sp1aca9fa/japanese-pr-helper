# PR Helper

A Rails web application that helps users navigate the Japanese Permanent Residency (PR) application process by organizing required documents, structuring guidance into section-based chats, and generating AI-assisted support per eligibility route.

Built as a portfolio project with real-world structure and production-oriented design.

---

## Overview

PR Helper guides users through Japan’s Permanent Residency routes by:

1. Selecting one of 9 official PR eligibility paths
2. Automatically generating structured section-based chats
3. Allowing document uploads in each section
4. Enabling updated document downloads directly from chat messages

Each user manages their own applications and associated documentation in an isolated, secure environment.

---

## Tech Stack

- **Backend:** Ruby on Rails
- **Database:** PostgreSQL
- **Frontend:** ERB + Bootstrap + Hotwire (Turbo)
- **Authentication:** Devise
- **File Storage:** Active Storage (Cloudinary)
- **AI Integration:** OpenAI API

---

## Authentication & Data Isolation

- Devise-based authentication
- Users can only see and manage their own:
  - Applications
  - Chats
  - Uploaded documents
  - Generated files

All associations are scoped to the current user.

---

## PR Routes Supported

Users select one of the following Permanent Residency eligibility paths:

1. **Spouse / Child Route**
   Those who are either the spouse or biological child of:
   - A Japanese national
   - A permanent resident
   - A special permanent resident

2. **Long-Term Resident Route**
   Those who hold “Long-Term Resident” status.

3. **Work / Dependent Route**
   Those with work-related statuses such as:
   - Engineer/Specialist in Humanities/International Services
   - Skilled Labor
   - Dependent status

4. **Highly Skilled (80+ Points – Current Status)**
   4-(1)-A: Granted stay as Highly Skilled Professional or Designated Activities with 80 or more points.

5. **Highly Skilled (80+ Points – Retrospective)**
   4-(1)-B: Had 80 or more points one year prior to PR application.

6. **Highly Skilled (70+ Points – Current Status)**
   4-(2)-A: Granted stay as Highly Skilled Professional or Designated Activities with 70 or more points.

7. **Highly Skilled (70+ Points – Retrospective)**
   4-(2)-B: Had 70 or more points three years prior to application.

8. **Specially Highly Skilled Personnel (Confirmed)**
   5-(1): Confirmed as specially highly skilled personnel.

9. **Specially Highly Skilled Personnel (Not Confirmed)**
   5-(2): Not formally confirmed as specially highly skilled.

Each route dynamically determines the structure of the associated application chats.

---

## Chat System

When a user creates an application:

- Chats are automatically generated based on the selected PR route.
- Each chat represents a required section (e.g., income verification, residency history, tax documentation).
- Users can:
  - Upload supporting documents to specific sections
  - Receive AI-assisted guidance
  - Download generated documents directly from:
    - The chat window
    - Individual messages

---

## AI Integration

Chats are powered by the OpenAI API.

The AI assists with:

- Structuring explanations
- Clarifying requirements
- Drafting statements or summaries
- Organizing documentation

Currently:

- Requests are processed synchronously

This keeps the architecture simpler but may introduce latency during AI response generation.

---

## File Management

- Active Storage handles uploads
- Cloudinary stores files in production
- Documents are associated with:
  - Applications
  - Chats
  - Messages (depending on context)

Users can both upload and download documents tied to specific PR sections.

---

## Application Flow

1. User signs up / logs in
2. Selects one of the 9 eligibility paths
3. Creates a new PR application
4. System generates structured chats
5. AI assists within each chat
6. User uploads documents (if any)
7. System refines documents for the user to download (if any)

---

## Architecture Notes

### Core Models (Conceptual)

- `User`
- `Application Journey`
- `User Applications`
- `Chat`
- `Message`

## Local Setup

### 1. Clone the repository

git clone https://github.com/jonathankiichikimura/japanese-pr-helper.git

cd japanese-pr-helper

### 2. Install dependencies

bundle install

### 3. Database setup

rails db:create
rails db:migrate

## Purpose

This project demonstrates:

- Full-stack Rails architecture
- Complex model associations
- Scoped multi-tenant data design
- AI API integration
- File upload and retrieval systems
- Production-ready deployment considerations

While built as a portfolio project, the application is designed with real-world usability in mind for individuals seeking Permanent Residency in Japan.
