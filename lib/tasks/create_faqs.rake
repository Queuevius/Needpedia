namespace :faqs do
  desc "Create FAQs"
  task create: :environment do
    Faq.destroy_all
    faqs = Faq.insert_all! [{
                              created_at: Time.now, updated_at: Time.now,
                              question: 'What is Needpedia?',
                              answer: '<p>Needpedia is a wiki that was inspired by the idea of letting you see all your options side by side, but it’s grown into much more than that. The world needs people to come together over the best ideas on Earth, so we’ve decked Needpedia out with special new tools, such as the Layer System. To learn more about those visit Needpedia’s homepage.
</p>

<p>It’s also worth noting that Needpedia is unbelievably flexible. Whether it’s the name of a project you’re working on, or the name of a holiday, if it has a name and we didn’t have to ban it, it can have its own space on Needpedia. Where you and everyone else are free to list all problems with it. -Then list all ideas for solving those problems. To give you a sense of how adaptable this is, its voting features could be used to literally create, propose, and vote on the creation of new holidays. Or words.</p>

<p>By the way we also invite you to do that with Needpedia, we’ve given you the tools to list every problem, idea, and proposal for Needpedia as well.</p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: 'Who owns Needpedia?',
                              answer: '<p>Needpedia’s founder, Anthony Brasher, to put it simply. But the plan is to operate Needpedia democractically as a digital direct democracy, then to transition into a fully decentralized model as the challenges to this are gradually discovered and resolved.</p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "Can't I already look up information on the internet?",
                              answer: '<p>Yes but it takes time and energy to search through a bunch of different search results, and at the end of the day, how do you know you actually got to see the best content? Needpedia displays all your options side by side. And provides tools that let you debate, and even ask for help with things through its time bank.</p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "What can normal people do with Needpedia?",
                              answer: '<p>The simplest answer is that you can see all your options for problems, listed side by side, and rated. Its a wiki for problem solving, which is automatically pretty useful. -Once we have enough content and users. For now we’re just getting started.</p>
<p>Fortunately we can start with a few areas in particular: “Earth” will have global discussions, and if you type in the name of your country or city you might find some cool projects. Needpedia also has a time bank, and you’ll hopefully be able to find help with things there. </p>
<p>Mind you, everyday people also tend to have projects, businesses and orgs they like to work on or with, and they’ll all be free to use Needpedia to crowdsource ideas and resources for them.</p>
<p>One of the most interesting prospects about Needpedia is that we could even use it to edit culture itself. As long as it has a name (and isn’t banned) we can use Needpedia to list all the problems we experience with it. And to share all our ideas and proposals regarding it. </p>
<p>And for anyone wondering, discussion of sex and drugs are absolutely welcome, we’ve built an archive for all practical human knowledge and we intend to use it. -Plus you’d be surprised by how quickly information like that can save lives.</p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "Is it free?",
                              answer: '<p>Yes but we ask that people pitch in. We don’t sell ads or any of the other garbage other sites do. Patreon makes it possible to donate a dollar a month, if even a fraction of our users contribute that we’ll be doing fine.</p><p>In time we plan on making all expenses public.</p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "Is it a wiki or a social media site?",
                              answer: '<p>It’s both. It all started as a wiki for solutions, but it was obvious we needed to do more than just list ideas, we need tools for working on them. Social media sites let people share information and build networks, so it seemed essential Needpedia have a social media section too. We also think it’s exciting imagining what a social media site could become combined with a wiki for ideas for problems. Instead of one business trying to balance development budgets with every other business concern, Needpedia lets everyone share their ideas, and if people like ‘em, they can either find funding for them, or programmers who think it’s a good enough idea to volunteer.</p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "What about hackers?",
                              answer: '<p>Hackers are a serious concern for any website, fortunately we’re not the first people to have to deal with them. And we don’t need sensitive information from users to operate, so the way we see it is that if banks can survive hackers, Needpedia can too. </p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "What about hackers?",
                              answer: '<p>Hackers are a serious concern for any website, fortunately we’re not the first people to have to deal with them. And we don’t need sensitive information from users to operate, so the way we see it is that if banks can survive hackers, Needpedia can too. </p>'
                            },
                            {
                              created_at: Time.now, updated_at: Time.now,
                              question: "Isn’t it dangerous for votes to be transparent?",
                              answer: '<p>If you are not completely certain it is safe for people to see your vote:</p><ol style="list-style-type: upper-alpha;">
    <li>do not vote, and</li>
    <li>contact us immediately. We care a great deal about this issue and hope to innovate technologically. Therefore any and all information about this from our users experiencing this is invaluable.</li>
</ol>
<p>For most people voting will be completely safe, but we already have ideas for what can be done when it&rsquo;s not.</p>'
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "What about problems that have no solutions?",
                              answer: "<p>They'll continue having no solutions. -But the quality and organization of the discussions surrounding them will be increased dramatically. -People won't have to repeat themselves anymore, they can just link people to the same discussion everyone had last time, on the wiki for all ideas. -Where there’s special communication tools, and the ability to revisit it whenever you want. On Needpedia ideas take on lives of their own, so even if the person who had them has absolutely no chance of implementing them, if other people like it, they can keep chipping away at it. Theoretically an idea some random kid had one day could grow into an entire citizen-expert-coalition with hundreds of people working on it, because on Needpedia the only question is whether an idea’s any good. There’s no political “parties” or politicians either, so the problem solving process is a lot simpler. There’s just ideas, and tools for refining them.</p>"
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "What if people try to use it to harm people?",
                              answer: "<p>Our Terms Of Service agreement prohibits the same kinds of behavior as any other site, and our users have tools to flag malicious content, like any other site.</p><p>In fact, some of our features may provide safer alternatives than what a lot of people are using now. -For instance, every time a babysitter uses Craigslist to meet a new client, they're walking into the house of an anonymous user. Anonymity can be fatal. Needpedia offer users a way to network differently than that, not only will accounts not be anonymous, we’ve made tools that let you see things like what pages they’re tracking, and what debates they’ve started. Things like these don’t do much to verify an account on their own, but combined, they make it hard for people to make scam accounts. Every single token or post they create can be flagged, so in order for you to see an account that looks normal, it had to post a lot of content that other people were cool with. And if you see an account that doesn’t offer you very much information, that itself becomes a red flag that tells you they might not be a regular user.</p>
<p>To be frank it also tells you if they’re the kind of person you’d want to work with or be around. Especially once someone gets mad in a debate, they tend to hsow their true colors pretty quickly.</p>
<p>So be sure to conduct yourself intelligently, everyone can see what you write here. And, we talk about everything here, so anger’s basically inevitable, stay constructive, or vent somewhere else. (we also recommend checking out the conflict resolution layers, where everything’s discussed using specialized conflict resolution formulas)</p>"
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "What about people in 3rd world countries?",
                              answer: "<p>You’d be surprised by how quickly a dozen used smartphones and a little funding can be transformed into internet cafes. -Each of which is capable of serving hundreds of people, (at least in terms of voting, and bartering)</p>"
                            }, {
                              created_at: Time.now, updated_at: Time.now,
                              question: "What can I do to help?",
                              answer: "<p>We need content, so even if all you can do is post about one idea you think is important or interesting, that really helps. And if you then copy and paste your post’s URL, to other websites, it will promote your idea and Needpedia at the same time. That’s one of the coolest things about this project. We’re really, basically just asking people to work on stuff that’s important or interesting to them.</p>
<p>We could also use Patreon commitments, even at the 1 or 5 dollar level they’re extremely useful because they let us know roughly how much we’ll have next month. (as opposed to a larger one time payment, which is great but harder to budget with). If even 5% of our users pitched in a few bucks a month we’d have enough to run the site and develop new features.</p>
<p>Promoting the site and protecting ourselves legally are expensive though, so if you can, please donate. </p>
<p>Another thing that helps us is people’s art. Capture it somehow and share it with us. We can use it for promotional material, and you’re also welcome to use it to make your own posts about Needpedia more interesting as well. Instead of donating to us so we can make an ad, you can effectively make one for us yourself. Word of mouth is powerful so even if you can’t make art, you can still help us spread the word. </p>"
                            }
                           ]
  end
end


