const aws = require("aws-sdk")
const https = require("https")

aws.config.update({region: "eu-central-1"});

exports.handler = async (event) => {
    return new Promise((resolve, reject) => {
        https.get(`https://www.apple.com/de/shop/fulfillment-messages?parts.0=${process.env.part_code}&location=${process.env.postal_code}`, (res) => {
            let data = "";

            res.on("data", (dataChunks) => {
                data += dataChunks;
            })

            res.on("end", () => {
                console.log("Got data with: \n", data);

                const dataJson = JSON.parse(data);

                if (dataJson.head.status !== undefined && dataJson.head.status === 200) {
                    const stores = dataJson.body.content.pickupMessage.stores
                    if (stores !== undefined) {
                        if (stores.length > 0) {
                            let message = "Congratulations, your part is available on these stores:\n"
                            let available = false;

                            stores.filter(store =>
                                process.env.city === undefined ||
                                (process.env.city === store.retailStore.address.city)
                            ).forEach(store => {
                                if (store.partsAvailability !== undefined &&
                                    store.partsAvailability[0].pickupDisplay !== "unavailable" &&
                                    !store.partsAvailability[0].storePickupQuote.include("gegenwärtig nicht verfügbar")) {
                                    available = true;
                                    const retailStore = store.retailStore;

                                    message += "\n" + retailStore.address.companyName
                                        + "\nGo make reservation at: " + store.reservationUrl
                                        + "\nThe store address is: ";

                                    Object.keys(store.address).sort().forEach(key => {
                                        message += "\n\t" + store.address["key"]
                                    });

                                    message += "\nAnd the store is opened on:";
                                    retailStore.storeHours.forEach(storeHour => {
                                        message += `\n\t ${storeHour.storeDays}: ${storeHour.storeTimings}`;
                                    });

                                    if (retailStore.storeHolidays !== undefined && retailStore.storeHolidays.length > 0) {
                                        message += "\nWith caveats holidays: ";
                                        retailStore.storeHolidays.filter(storeHoliday => storeHoliday.closed).forEach(storeHoliday => {
                                            message += `\n\t[${storeHoliday.description}] Date: ${storeHoliday.date} (${storeHoliday.comments})`;
                                            if (storeHoliday.hours !== null) {
                                                message += `Hours: ${storeHoliday.hours}`;
                                            }
                                        });
                                    }

                                    message += "\n";
                                } else {
                                    console.log(`Item is not available in store Apple ` + store.storeName.replaceAll(" ", ""));
                                }
                            });

                            if (available) {
                                const ses = new aws.SES();

                                const params = {
                                    Destination: {
                                        ToAddresses: JSON.encode(process.env.emails_to)
                                    },
                                    Messages: {
                                        Subject: {
                                            Charset: "UTF-8",
                                            Data: "Availability Found!"
                                        },
                                        Body: {
                                            Text: {
                                                Charset: "UTF-8",
                                                Data: message
                                            }
                                        }
                                    },
                                    Source: process.env.email_from
                                }

                                ses.sendEmail(params, (err, sesData) => {
                                    if (err) {
                                        console.error("Error sending email with message: ", err.message);
                                        reject(err.message);
                                    } else {
                                        console.log("Successfully sent email with data: ", sesData);
                                        resolve(sesData);
                                    }
                                });
                            }
                        } else {
                            console.log("There is no store near the the postal code.");
                        }
                    } else {
                        console.error("Stores data is not given by apple server.");
                    }
                } else {
                    reject("Got error while fetching with message ");
                }
            })
        }).on("error", (e) => {
            console.error(e.message);
        })
    })
}