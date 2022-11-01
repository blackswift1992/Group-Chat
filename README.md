Group Chat is an app where people can chat with each other. This app includes a full CrUD cycle for messages and user accounts. Were taken into account as positive as negative user interaction scenarios. The application is based on Firestore/Firebase, Swift, UIKit, AutoLayout, GCD, CocoaPods, OOP, MVC, etc.

Here video presentation of the app on Youtube: https://www.youtube.com/...

Below there are some screenshots:

1)First screens that user meets when the app runs

<img height="420" alt="Screenshot 2022-11-01 at 18 59 38" src="https://user-images.githubusercontent.com/113255680/199307262-624537cc-0bbf-4fee-aaad-f526f738c141.png"> <img height="420" alt="Screenshot 2022-11-01 at 19 01 00" src="https://user-images.githubusercontent.com/113255680/199307290-31f14d31-7a53-4704-a271-b0fd4c52e84e.png"> <img height="420" alt="Screenshot 2022-11-01 at 19 07 11" src="https://user-images.githubusercontent.com/113255680/199307333-250af988-0943-45f1-aa7c-ca82fec6917a.png">

2)If something goes wrong, the user will receive tips to solve the problem.

<img height="420" alt="Screenshot 2022-11-01 at 19 02 50" src="https://user-images.githubusercontent.com/113255680/199309721-a067517b-e240-420a-94c4-acec4c731b70.png"> <img height="420" alt="Screenshot 2022-11-01 at 19 09 09" src="https://user-images.githubusercontent.com/113255680/199309742-4fd729be-d0c2-4cdb-b936-32dacdb6f97e.png">

3)Next, a special view will appear where the user can put his data. This view is used when the user also wants to edit his account information. First name is necessary.

<img height="420" alt="Screenshot 2022-11-01 at 19 13 26" src="https://user-images.githubusercontent.com/113255680/199311885-aec0084b-2fb3-4b50-93f5-79dc8badd644.png"> <img height="420" alt="Screenshot 2022-11-01 at 19 16 51" src="https://user-images.githubusercontent.com/113255680/199312449-2a0bde34-b904-47da-b1fa-9b1fd5a60214.png">

4)After that chat opens. Here you can write, edit, delete your messages. Edited messages are marked as "edited". In the right corner is a menu where the user can edit, delete his account or leave the chat.

<img height="420" alt="Screenshot 2022-11-01 at 19 19 50" src="https://user-images.githubusercontent.com/113255680/199314627-d6b30ea4-2011-44c9-8c12-e2f80ec95664.png"><img height="420" alt="Screenshot 2022-11-01 at 19 22 35" src="https://user-images.githubusercontent.com/113255680/199314669-5b02fd48-16bd-4c76-b534-3badf6413981.png"><img height="420" alt="Screenshot 2022-11-01 at 19 23 44" src="https://user-images.githubusercontent.com/113255680/199314697-09399eb7-5402-4c0b-8902-0c1554094cfe.png"><img height="420" alt="Screenshot 2022-11-01 at 19 24 26" src="https://user-images.githubusercontent.com/113255680/199314726-2d784331-3e75-46f0-839a-6cd695ec24ac.png">

5)When there are 3 or more users in the chat, the interlocutor's avatar changes to the standard group picture. Also, each user has an individual name color in the group chat. This helps to understand who you are writing to.

<img height="420" alt="Screenshot 2022-11-01 at 19 29 50" src="https://user-images.githubusercontent.com/113255680/199318035-2008dbdc-20c7-4b39-9f69-8b48181c6037.png">

6)There are also some warnings for the user. One of them appears when the user tries to edit a message with an empty string. The other one appears when the user tries to delete his account.

<img height="420" alt="Screenshot 2022-11-01 at 19 25 50" src="https://user-images.githubusercontent.com/113255680/199318830-cde06334-f30b-4a42-8e24-276ec55005bf.png"> <img height="420" alt="Screenshot 2022-11-01 at 19 26 54" src="https://user-images.githubusercontent.com/113255680/199318867-e25b0a5f-6eea-43a7-a8e1-5f5b2fc7143d.png">

7)Deleting an account is animated with the blinking word "Deleting..." and the blurred background.

<img height="420" alt="Screenshot 2022-11-01 at 19 38 37" src="https://user-images.githubusercontent.com/113255680/199319656-67502019-c64a-480a-9be7-a6cd63d2fd41.png">

8)Some special negative scenarios were taken into account. When a user tries to log in, the application checks if all user data exists in Firestore. If something goes wrong, the application will ask the user to specify his data again. Another negative case can happen when a user tries to delete an account and something goes wrong in the middle (some data has been deleted and some hasn't yet). So in this case, the application asks the user to specify his data again and try to delete one more time.

<img height="420" alt="Screenshot 2022-11-01 at 19 32 17" src="https://user-images.githubusercontent.com/113255680/199322302-c8e3e0e8-d5ef-4269-a54d-37f86d6907a3.png"> <img height="420" alt="Screenshot 2022-11-01 at 19 34 15" src="https://user-images.githubusercontent.com/113255680/199322338-fc05d438-4402-4d9e-ba0d-5cbe053cb492.png"> <img height="420" alt="Screenshot 2022-11-01 at 19 39 32" src="https://user-images.githubusercontent.com/113255680/199322352-75b98818-002c-4e28-8c75-0b65d62fa10b.png">
