Code license: GNU LGPL version 2

Image license: CC Attribution-ShareAlike 3.0

Plugin dependencies: none (bucket, default, and fire are supported, however)


This is a fork of 0gb.us' landclaim mod http://forum.minetest.net/viewtopic.php?id=3679.


Imagine the entire map is divided into chunks. You place your land rush land claim block and it protects that chunk (then the land claim block disappears).

Chunk size is configurable, default is 16x16. There are three stages of vertical protection: 
   -30 thru 120
   
   120 thru vertical map limit, 
   
   -200 thru -30.
   
This is a partial protection mod. This is intended for PvP type maps.

1) Your areas are fully protected if you are offline.

2) You are not protected if you are online, but you will receive chat messages when somebody starts to grief one of your protected areas. Anybody you have shared the area with will also be notified. The griefer also gets a chat message that they are griefing in case it's an accident. This way you can initiate a conversation with the griefer or go and fight them.


There are two modes for this Mod

1) You are required to claim areas you wish the build on. You cannot dig or build in unclaimed areas. The exception to this are ladders, you can place and dig ladders in unclaimed areas to get yourself out of a hole or something like that. With this mode you really have to give people a few land rush land claim blocks when they first log in. Edit init.lua and change requireClaim = true to use this mode.

2) Anybody can dig or build in unclaimed areas. Edit init.lua and change requireClaim = false to use this mode.

Craft Recipe

S = Stone

I = Steel Ingot

M = Mese / Mese Crystal

S I S

I M I

S I S

Chat Commands

/showarea - Draws a box around the current chunk you are in

/landowner - shows the current owner of the chunk you are in

/unclaim - remove your claim on the current chunk you are in

/sharearea <name> - shares the area with <name>

/unsharearea <name> - removes <name> from the share

