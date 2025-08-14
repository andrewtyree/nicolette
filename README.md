# Nicolette

A comprehensive workforce scheduling application built with Flutter that manages assignment rotations based on complex rule sets, worker qualifications, and equity distribution algorithms.

## Overview

Nicolette automates the creation and management of work schedules by:
- Applying configurable business rules to assignment distribution
- Ensuring equitable workload distribution across all workers
- Managing time-off requests and assignment swaps
- Generating professional schedule documents
- Tracking worker absences and leave balances

## Key Features

### 🔄 Intelligent Assignment Distribution
- **Rule-Based Scheduling**: Complex rule engine supports permanent assignments, preferred worker lists, and conditional logic
- **Equity Algorithms**: Year-to-date tracking with weighted probability distribution ensures fair assignment allocation
- **Priority-Based Assignment**: Configurable assignment priority hierarchy for optimal worker development

### 👥 Worker Management
- **Flexible Worker Roles**: Support for special designations (Senior Workers) with specific operational requirements
- **Assignment Preferences**: Configurable preferred worker lists for specialized assignments
- **Qualification Tracking**: Worker eligibility and specialization management

### 📅 Schedule Management
- **Dynamic Schedule Generation**: 3-4 week advance scheduling with daily modification capabilities
- **Assignment Swap System**: Worker-initiated swap requests with approval workflows
- **Conflict Resolution**: Automated rule priority hierarchy with manual override capabilities

### 🏢 Assignment Types
- **Priority Assignment Type A**: Highest priority assignments for optimal distribution
- **Priority Assignment Type B**: Secondary priority assignments
- **Processing Center**: Specialized assignment location
- **Evening Assignments**: Assignments requiring senior worker oversight
- **Remote Assignments**: Off-site locations with dedicated coverage protocols
- **Front Desk Duty**: Walk-in service assignments (AM/PM shifts)

### ⏰ Time-Off Management
- **Leave Categories**: Vacation, sick, personal, wellness, and comp time tracking
- **Hour-Based Tracking**: Full-day (8hrs) and half-day (4hrs) increment support
- **Protected Leave**: FMLA and other legally protected absence management
- **Comp Time System**: Weekend assignment compensation tracking and usage

### 📊 Reporting & Analytics
- **Equity Reports**: Year-to-date assignment distribution analysis
- **Coverage Statistics**: Assignment fulfillment and gap analysis
- **Worker Performance**: Assignment completion and absence tracking

## Technical Architecture

### Cross-Platform Support
- **Mobile**: iOS and Android native applications
- **Desktop**: Windows, macOS, and Linux support
- **Web**: Browser-based access for universal compatibility

### Database Design
- **Worker Profiles**: Qualifications, roles, and preferences
- **Assignment Definitions**: Types, priorities, and business rules
- **Schedule Tables**: Generated assignments with audit trails
- **Leave Management**: Time-off requests and balance tracking
- **Rule Engine**: Configurable business logic and constraints

### Modern Flutter Stack
- **Responsive UI**: Adaptive design for all screen sizes
- **State Management**: Robust state handling for complex scheduling logic
- **Local Storage**: Offline capability with cloud synchronization
- **Export Capabilities**: PDF generation and calendar integration

## Project Roadmap

### Phase 1: Core Foundation (Weeks 1-4)
- [ ] Project setup and database schema design
- [ ] Worker management system
- [ ] Basic assignment type configuration
- [ ] Simple rule engine implementation
- [ ] Schedule generation algorithm (basic version)

### Phase 2: Rule Engine & Scheduling (Weeks 5-8)
- [ ] Advanced rule engine with priority hierarchy
- [ ] Equity calculation and weighted probability distribution
- [ ] Senior worker designation and constraints
- [ ] Remote assignment coverage protocols
- [ ] Schedule conflict detection and resolution

### Phase 3: Time-Off & Swap Management (Weeks 9-12)
- [ ] Leave request system with categorization
- [ ] Hour-based time tracking (full/half days)
- [ ] Comp time earning and usage system
- [ ] Assignment swap request workflows
- [ ] Protected leave (FMLA) compliance

### Phase 4: User Interface & Experience (Weeks 13-16)
- [ ] Professional schedule document generation
- [ ] Responsive dashboard for all user types
- [ ] Worker self-service portal for requests
- [ ] Administrative interfaces for deputy chiefs
- [ ] Mobile-optimized schedule viewing

### Phase 5: Advanced Features (Weeks 17-20)
- [ ] Historical data import capabilities
- [ ] Advanced reporting and analytics
- [ ] Notification system for schedule changes
- [ ] Audit trail and change tracking
- [ ] Performance optimization and testing

### Phase 6: Deployment & Integration (Weeks 21-24)
- [ ] Multi-platform build and testing
- [ ] Data migration tools
- [ ] User training documentation
- [ ] Production deployment
- [ ] Post-launch support and refinements

## Future Enhancements

### Advanced Scheduling Features
- **Machine Learning**: Predictive assignment optimization based on historical patterns
- **Integration APIs**: Calendar system integration (Outlook, Google Calendar)
- **Mobile Notifications**: Push notifications for schedule changes and approvals
- **Advanced Analytics**: Predictive modeling for staffing needs

### Enterprise Features
- **Multi-Location Support**: Manage multiple office locations from single system
- **Role-Based Permissions**: Granular access control for different user types
- **API Development**: External system integration capabilities
- **Advanced Reporting**: Executive dashboards and compliance reporting

### User Experience Improvements
- **Dark Mode**: Alternative UI theme
- **Accessibility**: WCAG compliance for universal access
- **Internationalization**: Multi-language support
- **Offline Mode**: Full functionality without internet connectivity

## Contributing

This project uses a generic terminology system to maintain privacy while supporting open-source development. When contributing:

- **Workers** refers to individuals receiving assignments
- **Assignment Types** refers to different duty categories
- **Senior Workers** refers to individuals with special operational responsibilities
- Follow the established naming conventions in code and documentation

## License

[To be determined - suggest MIT or Apache 2.0 for open source]

## Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart 3.0 or higher
- IDE with Flutter support (VS Code recommended)

### Installation
```bash
git clone https://github.com/andrewtyree/nicolette.git
cd nicolette
flutter pub get
flutter run
```

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Test thoroughly across platforms
5. Submit a pull request

---

*Nicolette - Intelligent workforce scheduling for modern organizations*