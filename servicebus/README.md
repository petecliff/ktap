# Service Bus Demo
_*When you're done, don't forget to tear the whole lot down so you've not got random resources hanging around*_

This is a service bus demo using Topics, Subscriptions and some Actions and Rules.

The Service Bus is defined in `servicebus.bicep` and a demo param file `servicebus.demo.bicepparam. The template can be deployed via the command line or in the demo I showed a build pipeline (`azurepipelines.yaml`) that just bundles the infrastructure files into a pipeline artifact. I then showed a classic Release built using that pipeline artifact and the ARM Template Deployment task to push this into Azure. If you don't have Azure DevOps access just use the CLI (see `commands.txt` if needed).

Once deployed, you can see it working with the supplied clients - one sender and two receivers. These are written in node so you'll need that installed and are minor modifications to the tutorial code from Microsoft: https://learn.microsoft.com/en-us/azure/service-bus-messaging/service-bus-nodejs-how-to-use-queues?tabs=passwordless

Main change was I added some `applicationProperties` to the message. This is referred to as `customProperties` or even `userProperties` in other docs I saw (maybe - it was late and the docs are not 100% clear on this imho). These allow user properties to be added to the message that can then be referenced in the SQL-like filter and action expressions with `user.` annotation. For example:

```
    { body: "Kind of Blue", applicationProperties: { "genre": "jazz", "rating": 5 } },
```

means we can add a filter:

```
resource johnnyServiceBusRule 'Microsoft.ServiceBus/namespaces/topics/subscriptions/rules@2021-11-01' = {
  name: 'johnnyrules'
  parent: johnnyMusicTopicSubscription
  properties: {
    filterType: 'SqlFilter'
    sqlFilter: {
      sqlExpression: 'user.genre != \'jazz\''
      requiresPreprocessing: false
    }
  }
}
```
where that `user.genre` is the applicationProperties genre.

To try the demo for yourself, first get the service bus running in an Azure subscription somewhere near you.

Next grab the primary connection string and paste that into the `.env` file under `/client`. Finally open a couple of terminal windows - in one run one of the receivers and then quickly after run the sender in the other window:

```
Terminal 1: node --env-file .\env chuck.js
Terminal 2: node --env-file .\env sender.js
```

The receivers have a timer that sets the wait time and then they stop listening and close. If you need more time you can extend the life of the receiver around line 31 of them:
```
    // Waiting long enough before closing the sender to send messages
    await delay(10000);
```

This pushes those messages into the service bus and you can see they get queued on each of the subscriptions - all, johnny and chuck - and then (if you run the command above) chuck receives the messages and all is good. The messages remain in the all and johnny subscriptions so you can then run:

```
node --env-file .\env johnny.js
```
to see the content of that queue. Remember the filter and that Johnny Hates Jazz.

_*When you're done, don't forget to tear the whole lot down so you've not got random resources hanging around*_
