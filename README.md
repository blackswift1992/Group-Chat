# Group Chat
Group Chat is an app where people can chat with each other. This app includes a full CrUD cycle for messages and user accounts. Were taken into account as positive as negative user interaction scenarios. The application is based on Firestore/Firebase, Swift, UIKit, AutoLayout, GCD, CocoaPods, OOP, MVC, etc. There are some animations and vibration responses in the app.

# Video presentation on Youtube (clickable):

[![IMAGE ALT TEXT HERE](https://img.youtube.com/vi/-MPezfT8AD4/0.jpg)](https://www.youtube.com/watch?v=-MPezfT8AD4)

# Screenshots:

1)First screens that user meets when the app runs. "⚡️GroupChat" is animated. Authorization, registration, and user data loading have an activity indicator.

<img height="450" alt="Screenshot 2022-11-01 at 18 59 38 2" src="https://user-images.githubusercontent.com/113255680/199349944-ae4286b9-40e1-4c93-9df4-0c21cace1dc6.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 01 00" src="https://user-images.githubusercontent.com/113255680/199349968-2a151849-42a3-43c4-834e-9639222a9d30.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 07 11" src="https://user-images.githubusercontent.com/113255680/199349987-a461efd8-5560-4ac9-be42-c19019910a65.png">

2)If something goes wrong, the user will receive tips to solve the problem.

<img height="450" alt="Screenshot 2022-11-01 at 19 02 50" src="https://user-images.githubusercontent.com/113255680/199350126-83927243-7835-4933-907c-12249f7a012e.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 09 09" src="https://user-images.githubusercontent.com/113255680/199350154-c654571f-fae7-4e89-9531-9a357d47195d.png">

3)Next, a special view will appear where the user can put his data. This view is used when the user also wants to edit his account information. Also this view is used when  an account deleting might go wrong. A first name must be provided.

<img height="450" alt="Screenshot 2022-11-01 at 19 13 26" src="https://user-images.githubusercontent.com/113255680/199350288-c3e10fc7-4286-45ae-8e22-6795185d8350.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 16 51" src="https://user-images.githubusercontent.com/113255680/199350318-39beb265-6cbc-4331-963a-7a533eddd8cf.png">

4)After that chat opens. In the right corner is a menu where the user can edit, delete his account or leave the chat. 

<img height="450" alt="Screenshot 2022-11-02 at 03 26 17" src="https://user-images.githubusercontent.com/113255680/199373634-70b88bf3-ee66-486a-ae2b-7bce92ed63f7.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 19 50" src="https://user-images.githubusercontent.com/113255680/199350562-a599bd33-9ac8-4d89-8656-bdebb7fe9406.png"> 

5)Of course user can write, edit, delete your messages. A long press on a message opens an edit menu where the user can choose an action (delete, edit). Edited messages are marked as "edited". 

<img height="450" alt="Screenshot 2022-11-01 at 19 22 35" src="https://user-images.githubusercontent.com/113255680/199350607-884073a3-c87b-4a7d-907d-a1ab2a28f941.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 23 44" src="https://user-images.githubusercontent.com/113255680/199350626-09461ba6-3563-4dd7-ab1f-23f4406f8c73.png"> <img height="450" alt="Screenshot 2022-11-02 at 00 13 33" src="https://user-images.githubusercontent.com/113255680/199352429-e64c2910-c740-4644-8e7c-1fedcc6a1b29.png">

6)When there are 3 or more users in the chat, the interlocutor's avatar changes to the standard group picture. Also, each user has an individual name color in the group chat. This helps to understand who you are writing to.

<img height="450" alt="Screenshot 2022-11-01 at 19 29 50" src="https://user-images.githubusercontent.com/113255680/199351083-6992b23c-7dda-46ec-968e-59f8d8d055b9.png">

7)There are also some warnings for the user. One of them appears when the user tries to edit a message with an empty string. The other one appears when the user tries to delete his account.

<img height="450" alt="Screenshot 2022-11-01 at 19 25 50" src="https://user-images.githubusercontent.com/113255680/199351231-89f08a61-8fe7-4b52-90a5-68163094aae2.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 26 54" src="https://user-images.githubusercontent.com/113255680/199351255-66c63dda-4e9a-4629-b267-79edd85ba684.png">

8)Deleting an account is animated with the blinking word "Deleting..." and the blurred background.

<img height="450" alt="Screenshot 2022-11-01 at 19 38 37" src="https://user-images.githubusercontent.com/113255680/199351340-18682422-ad94-4fb7-9bef-678dd96b0e9b.png">

9)Some special negative scenarios were taken into account. When a user tries to log in, the application checks if all user data exists in Firestore. If something goes wrong, the application will ask the user to specify his missing data. Another negative case can happen when a user tries to delete an account and something goes wrong in the middle (some data in Firestore was lost). So in this case, the application asks the user to specify his missing data and try to delete account one more time.

<img height="450" alt="Screenshot 2022-11-01 at 19 32 17" src="https://user-images.githubusercontent.com/113255680/199351409-c24f66bc-de16-4ad8-baa9-be95ca2997d4.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 34 15" src="https://user-images.githubusercontent.com/113255680/199351437-dd0530b3-3615-402a-9177-7dc7764d4d88.png"> <img height="450" alt="Screenshot 2022-11-01 at 19 39 32" src="https://user-images.githubusercontent.com/113255680/199351461-a0018e02-2acc-4579-a52f-f7b751e6fb3c.png">

