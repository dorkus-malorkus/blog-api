

  -- insert authors
  INSERT INTO authors(handle, email, active, searchable)
    VALUES
      ('webmaster', 'webmaster@dorkusmalorkus.org', true, false),
      ('slackjockey', 'slackjockey@dorkusmalorkus.org', true, true);

  -- insert posts.
  INSERT INTO posts(author, header, subheader, active, searchable, body)
    VALUES
      ('webmaster', 'Privacy Policy', '', true, false,
        '<img src="/privacy-policy-header.png" style="width: 100%;"></img><p>Dorkus Malorkus believes that all folks are entitled to privacy and deplores the sharing of personal information to or by any third party.</p>
<p>We track user activity, anonymously, soley for our own purpose: To gauge interest in our content as well as to attribute traffic to it&apos;s respective source.</p>'),
      ('webmaster', 'About Us', 'Dorkus Malorkus', true, true,  -- should be searchable only temporarily.
        '<img src="/about-us-header.png" style="width: 100%;"></img><p>Dorkus Malorkus is the result of an ongoing collaboration of likeminded individuals contributing to a collective knowledgebase.</p>
<p>The primary role of this site is to promote and disseminate the documentation and knowledge resulting from individual projects and collaborations.</p>
<p>All content herein, unless stated otherwise therein, is available under the <a href="https://creativecommons.org/licenses/by/4.0/"><i>Creative Commons Attribution 4.0</i> license</a>.
<p>
  <a href="https://creativecommons.org/" title="Creative Commons Home"><img src="/creativecommons-license-cc-logo.png"></img></a>
  <a href="https://creativecommons.org/licenses/by/4.0/" title="Creative Commons Attribution 4.0 License"><img src="/creativecommons-license-by-logo.png"></img></a>
</p>'),
      ('webmaster', 'Login', 'Secure Author Login', true, false, '<h3>under construction.</h3>'),
      ('webmaster', 'Welcome!', 'We&apos;re Glad You&apos;re Here!', true, true,
        '<img src="/welcome-header.png" style="width: 100%;"></img><p>It&apos;s a BLOG! At least it will be once we have some more content. Rest assured that content is being generated as you read this and will soon grace these hallowed pixels!</p>
<p>Thanks for stopping by. Please check back soon for more updates!</p>'),
      ('webmaster', 'webmaster', 'Master and Moderator of all things Web', true, false, '<img src="/webmaster-profile.png" style="max-width: 600px;"></img><p>Charged with the grand task of disseminating the knowledge compiled by Dorkus Malorkus&apos; veritable <i>revolving door</i> of collaborators as well as providing a guiding moderation of the subsequent conversations to maintain a constructive discussion and promote the exchange of ideas.</p>
<p>Not a simple task, in the slightest, but Dorkus Malorkus&apos; ever-nimble webmaster is undoubtedly up to the task. Be sure to check back frequently to see what clever new forms this glorious machine takes on!</p>'),
      ('slackjockey', 'slackjockey', '...not in the crotch!', true, false, '<img src="/slackjockey-profile.png" style="max-width: 300px;"></img><p>Has been known to like stuff!</p><p><a href="http://github.com/slackjockey">REPOSITORIES</a><br/><a href="https://gist.github.com/slackjockey/">GISTS</a></p>');

  -- insert topics.
  INSERT INTO posts.topics(handle, post)
    VALUES
      ('policy', 'privacy-policy'),
      ('about', 'about-us'),
      ('login', 'login'),
      ('news', 'welcome'),
      ('profiles', 'webmaster'),
      ('profiles', 'slackjockey');
