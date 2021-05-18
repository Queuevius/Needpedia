# Needpedia2
Needpedia is intended to be the wiki for all possible solutions to any problem, with anything.

## Development
Before starting, it is important you have the desired environment, you would need to install
- Ruby (instructions for your operating system can be found here https://www.ruby-lang.org/en/documentation/installation/)
- PostgresQL (download instructions are here https://www.postgresql.org/)
- Node.js (Find the installation instructions at the Node.js website https://nodejs.org/en/download/)
- Yarn (To install Yarn, follow the installation instructions at the Yarn website https://classic.yarnpkg.com/en/docs/install)

If you have all these installed on your local machine now you can follow the bellow steps to setup this project locally

- clone the repo
- bundle install
- create DB, run command rails db:create
- run migrations, run command: rails db:migrate

## Environment variables for for development
RECAPTCHA_SECRET_KEY=6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe
RECAPTCHA_SITE_KEY=6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI

#### Optional

GENERAL_AREA_ID=1 (where 1 is the DB id of any Area post)

GENERAL_PROBLEM_ID=2 (where 2 is the DB id of any Area post)
