import functions = require('firebase-functions');
import admin = require('firebase-admin');
admin.initializeApp();

exports.scheduledBirthdays = functions.pubsub.schedule('every 24 hours').onRun((context) => {
    console.log('Connecting to the database');
    const birthdaysToNotifyForUser = new Map();

    return admin.database().ref('birthdays/').once('value', (snapshot) => {

        for (const [uid, value] of Object.entries(snapshot.val())) {
            console.log('User is: ' + uid);
            birthdaysToNotifyForUser.set(uid, getBirthdaysToNotify(value).map(bday => {
                return nextBirthdayTime(Object.values(bday)[0] + '').toDateString() + ' is ' + Object.keys(bday)[0] + '\'s birthday!';
            }));
        }

        notifyBirthdaysToUsers(birthdaysToNotifyForUser);
        
    });
});

// From the list of a user's birthday, extract those that should be notified
function getBirthdaysToNotify(birthdays: any): any[] {
    const selectedBdays = [];
    for (const [id, birthday] of Object.entries(birthdays)) {
        console.log('Birthday ID: ' + id + ' And Birthday is: ' + birthday);
        if (isBirthdayToBeNotified(birthday)) {
            selectedBdays.push(birthday);
        }
    }
    return selectedBdays;
}

// Check if a specific birthday should be notified
function isBirthdayToBeNotified(birthday: any): boolean {
    for (const [_, date] of Object.entries(birthday)) {
        console.log('Birthday date is: ' + date);
        const nextTime = nextBirthdayTime(date + '');
        console.log('Next birthday date is: ' + nextTime + ' and the difference in days is: ' + differenceInDays(new Date(), nextTime));
        if (differenceInDays(new Date(), nextTime) === 14) {
            return true;
        }
        if (differenceInDays(new Date(), nextTime) === 1) {
            return true;
        }
    }
    return false;
}

// Calculate the next birthday occurrence for a birthday. Is it this year or (if already passed) next year? 
function nextBirthdayTime(date: string): Date{
    const dateS = date + '';
    const parts = dateS.split('-', 2);
    const day = parts[0];
    const month = parts[1];
    const today = new Date();
    if (parseInt(month) > today.getMonth() || (parseInt(month) === today.getMonth() && parseInt(day) > today.getDay())) {
        //This year
        return new Date(today.getFullYear() + '-' + month + '-' + day)
    }
    // Next year
    return new Date((today.getFullYear()+1) + '-' + month + '-' + day)
}

// Difference in days between today and the next occurrence of a birthday
function differenceInDays(today: Date, nextBday: Date) : number {
    const diff = Math.abs(nextBday.getTime() - today.getTime());
    return Math.ceil(diff / (1000 * 3600 * 24)); 
}

// Retrieve FCM token for each user and send them the relevant notification
function notifyBirthdaysToUsers(birthdays: Map<string, string[]>) {
    // For each user, retrieve its token and notify birthdays
    birthdays.forEach((bdays: string[], user: string) => {
        admin.database().ref('tokens/').child(user).once('value', (snapshot) => {
            const token = Object.values(snapshot.val())[0];
            console.log('Token: ' + token);
            bdays.forEach(bday => {
                sendMessage(token + '', bday);
            })
        })
        .catch(error => console.log(error));
    });
}

// Create a payload and send a message to the specified FCM (firebase cloud messaging) token
function sendMessage(token: string, message: string) {
    console.log('Sending: ' + message + ' to ' + token);
    const payload = {
        notification: {
            title: 'Birthday coming up!',
            body: message
        }
   };

   admin.messaging().sendToDevice(token, payload)
   .catch(error => console.log(error));
}