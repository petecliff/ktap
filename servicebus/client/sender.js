const { ServiceBusClient } = require("@azure/service-bus");

const connectionString = process.env.CONNECTION_STRING;
const topicName = "songs";

//https://learn.microsoft.com/en-us/javascript/api/@azure/service-bus/servicebusmessage?view=azure-node-latest
const messages = [
    { body: "Kind of Blue", applicationProperties: { "genre": "jazz", "rating": 5 } },
    { body: "The Race for Space", applicationProperties: { "genre": "rock", "rating": 4 } },
    { body: "Born to Run", applicationProperties: { "genre": "rocknroll", "rating": 2 }  },
    { body: "Turn Back The Clock", applicationProperties: { "genre": "pop", "rating": 3 }  }
];

 async function main() {
    // create a Service Bus client using the connection string to the Service Bus namespace
    const sbClient = new ServiceBusClient(connectionString);

    // createSender() can also be used to create a sender for a queue.
    const sender = sbClient.createSender(topicName);

    try {
        // Tries to send all messages in a single batch.
        // Will fail if the messages cannot fit in a batch.
        // await sender.sendMessages(messages);

        // create a batch object
        let batch = await sender.createMessageBatch();
        for (let i = 0; i < messages.length; i++) {
            // for each message in the array

            // try to add the message to the batch
            if (!batch.tryAddMessage(messages[i])) {
                // if it fails to add the message to the current batch
                // send the current batch as it is full
                await sender.sendMessages(batch);

                // then, create a new batch
                batch = await sender.createMessageBatch();

                // now, add the message failed to be added to the previous batch to this batch
                if (!batch.tryAddMessage(messages[i])) {
                    // if it still can't be added to the batch, the message is probably too big to fit in a batch
                    throw new Error("Message too big to fit in a batch");
                }
            }
        }

        // Send the last created batch of messages to the topic
        const res = await sender.sendMessages(batch);
        console.log(res);

        console.log(`Sent a batch of messages to the topic: ${topicName}`);

        // Close the sender
        await sender.close();
    } finally {
        await sbClient.close();
    }
}

// call the main function
main().catch((err) => {
    console.log("Error occurred: ", err);
    process.exit(1);
 });