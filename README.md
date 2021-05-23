# Needpedia
Needpedia's goal is to create a community of devs who use it's "Layer System" and other tools to collaborate directly with users to optimize Needpedia, while others use it to optimize countless different things in the world. It can be used to do anything from support a volunteer organization halfway accross the world,  to making public all problems with an evil corporation in your own backyard. Which is why it needs to be an Open Source community instead of a business. (Most sponsors aren't going to like that)

That said, the tools we're making for activists and scientists can also be used for respectable/ethical businesses, so once Needpedia's doing well we plan on creating a separate, worker-owned, for-profit business that specializes in using the tools we've made here to serve businesses, and generate funding for legal defense, (for Needpedia). 

 Needpedia has an FAQ section here: https://needpedia.org/faq 
 a 'how to' section on the homepage at Needpedia.org 

*Please also remember that as far as I'm concerned, Needpedia's dev community is the backbone of this entire operation, so if there is Anything I can do to support you, or that we can add to this project to make it work better, I definitely want to know. My personal email address is Anthonydunn97202@gmail.com - Even if I can't answer your question I can probably find someone who can.
      -Anthony Brasher, Needpedia's founder



## Development
Before starting, it is important you have the desired environment, you'll need to install
- Ruby (instructions for your operating system can be found here https://www.ruby-lang.org/en/documentation/installation/)
- PostgresQL (download instructions are here https://www.postgresql.org/)
- Node.js (Find the installation instructions at the Node.js website https://nodejs.org/en/download/)
- Yarn (To install Yarn, follow the installation instructions at the Yarn website https://classic.yarnpkg.com/en/docs/install)

Once you have all these installed on your local machine, you can follow the bellow steps to setup this project locally

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
