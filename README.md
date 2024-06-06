# vpinball-floating-scores

Instructions on how to apply floating scores to a Visual Pinball table.

## Acknowledgements

The floating scores script was extracted from [Space Station (Wiliams 1987)](https://www.vpforums.org/index.php?app=downloads&showfile=12717) by nFozzy. Implementation of [Toxie's idea](http://www.vpforums.org/index.php?showtopic=39255).

## Game items

Since a lot of game items need to be added to the table I suggest you do this using [vpxtool](https://github.com/francisdb/vpxtool).

We are going to add a TextBox (only for the timer), a lot of Flashers and some Images.

* Make a backup of your table!
* Extract your existing table `vpxtool extract mytable.vpx`. That will create a folder `mytable` with all the files.
* Copy over all the gameitems from this repository.
* Merge the contents of this repository's `gametiems.json` with your own `gameitems.json`.
* Copy over all the images from this repository.
* Merge the contents of this repository's `images.json` with your own `images.json`.
* Re-assemble the table `vpxtool assemble mytable`.

## Table script

Currently, the system is set up for rom-based tables obly. It's also requesting the full NVRAM instead of looking at changes.
To make this work you need to add `UseVPMNVRAM = true` to the table script (place before LoadVPM, or otherwise calling core.vbs)
After that you can request the NVRAM with `Controller.NVRAM`

To make changed content of NVRAM available create a `Sub NVRAMCallback` (requires VPM 2.7 or newer)
The callback will receive an `Array` that contains the changes as an `Array(location, new value, old value)`

For Sys 11 the current score is located at the range `&h200` - `&h203`.

### Classes

Copy the contents of `floatingtext.vbs` to the end of your table script. It contains the classes `FloatingText` and `cAnimation`.

### Config variable

Keep in mind that not everybody likes these floating scores so make sure the user can disable it. On the original table they were only enabled for desktop mode:

```vbscript
Dim FloatingScores
FloatingScores = Table1.ShowDT 'Enable/Disable floating text scores  (Default: Table1.ShowDT)
'Does NOT play nicely with B2S at the moment.
'(In a multiplayer game, floating text will only appear for player 1)
```

### Setup

```vbscript
'Floating text
'*************

ScoreBox.TimerEnabled = FloatingScores


dim FTlow, FTmed, FThigh
InitFloatingText
Sub InitFloatingText()
	Set FTlow = New FloatingText
	with FTlow 
		.Sprites(0) = Array(FtLow1_1, FtLow1_2, FtLow1_3, FtLow1_4, FtLow1_5, FTlow1_6)
		.Sprites(1) = Array(FtLow2_1, FtLow2_2, FtLow2_3, FtLow2_4, FtLow2_5, FtLow2_6)
		.Sprites(2) = Array(FtLow3_1, FtLow3_2, FtLow3_3, FtLow3_4, FtLow3_5, FtLow3_6)
		.Sprites(3) = Array(FtLow4_1, FtLow4_2, FtLow4_3, FtLow4_4, FtLow4_5, FtLow4_6)
		.Sprites(4) = Array(FtLow5_1, FtLow5_2, FtLow5_3, FtLow5_4, FtLow5_5, FtLow5_6)
		
		.Prefix = "Font_"
		.Size = 29/2
		.FadeSpeedUp = 1/800
		.RotX = -37

	end With

	Set FTmed = New FloatingText
	With FTmed
		.Sprites(0) = Array(FtMed1_1, FtMed1_2, FtMed1_3, FtMed1_4, FtMed1_5, FtMed1_6)
		.Sprites(1) = Array(FtMed2_1, FtMed2_2, FtMed2_3, FtMed2_4, FtMed2_5, FtMed2_6)
		.Sprites(2) = Array(FtMed3_1, FtMed3_2, FtMed3_3, FtMed3_4, FtMed3_5, FtMed3_6)
		.Sprites(3) = Array(FtMed4_1, FtMed4_2, FtMed4_3, FtMed4_4, FtMed4_5, FtMed4_6)
		.Sprites(4) = Array(FtMed5_1, FtMed5_2, FtMed5_3, FtMed5_4, FtMed5_5, FtMed5_6)
		.Prefix = "Font_"
		.Size = 29
		.FadeSpeedUp = 1/1500
		.RotX = -37
	End With

	Set FThigh = New FloatingText
	With FThigh
		.Sprites(0) = Array(FtHi1_1, FtHi1_2, FtHi1_3, FtHi1_4, FtHi1_5, FtHi1_6)
		.Sprites(1) = Array(FtHi2_1, FtHi2_2, FtHi2_3, FtHi2_4, FtHi2_5, FtHi2_6)
		.Sprites(2) = Array(FtHi3_1, FtHi3_2, FtHi3_3, FtHi3_4, FtHi3_5, FtHi3_6)
		.Prefix = "Font_"
		.Size = 29*4
		.FadeSpeedUp = 1/3500
		.RotX = -37
	End With

End Sub

'A special keyframe animation called with big scores
dim aLutBurst : Set aLutBurst = New cAnimation
with aLutBurst
	.AddPoint 0, 0, 0
	.AddPoint 1, 130, 20 'up
	.AddPoint 2, 150, 14 'hold
	.AddPoint 3, 180, 20 'hold
	.AddPoint 4, 210, 14 'hold
	.AddPoint 5, 240, 20 'hold
	.AddPoint 6, 270, 14 'hold
	.AddPoint 7, 290, 20 'hold
	.AddPoint 8, 320, 14 'hold
	.AddPoint 9, 350, 20 'hold
	.AddPoint 10,350+130, 0 'down
	.Callback = "animLutBurst"
End With
Sub animLutBurst(aLVL)
	table1.ColorGradeImage = "RedLut_" & Round(aLVL)
ENd Sub
animlutburst 0

Const UseVPMNVRAM = true
dim LastSwitch : Set LastSwitch = Sw10
dim LastScore : LastScore = 0

Sub ScoreBox_Timer()
	Dim NVRAM : NVRAM = Controller.NVRAM
	dim str : str = _
	ConvertBCD(NVRAM(CInt("&h200"))) & _
	ConvertBCD(NVRAM(CInt("&h201"))) & _
	ConvertBCD(NVRAM(CInt("&h202"))) & _
	ConvertBCD(NVRAM(CInt("&h203")))		'sys 11 current score
	str = round(str)

	dim PointGain
	PointGain = Str - LastScore	
	LastScore = str

	if PointGain >= 90000 Then	'hi point scores
		PlaceFloatingTextHi PointGain, LastSwitch.x, LastSwitch.y	
		aLutBurst.Play
	elseif pointgain >= 2500 then 'medium point scores	
		ftmed.TextAt PointGain, Lastswitch.x, Lastswitch.Y
	elseif pointgain > 0 then	'low point scores
		ftlow.TextAt PointGain, Lastswitch.x, Lastswitch.Y
	end if
	'if debugstr <> "" then 
	'	if tb.text <> debugstr then tb.text = debugstr
	'end if

	FTlow.Update2
	FTmed.Update2

	FThigh.Update2
	aLutBurst.Update2
End Sub

Function ConvertBCD(v)
	ConvertBCD = "" & ((v AND &hF0) / 16) & (v AND &hF)
End Function

'Helper placer sub
Sub PlaceFloatingTextHi(aPointGain, ByVal aX, ByVal aY)	'center text a bit for the big scores
	aX = (aX + (table1.width/2))/2
	aY = (aY + (table1.Height/2))/2
	FThigh.TextAt aPointGain, aX, aY
End Sub

'Switch location handling, or at least the method I use
Sub aSwitches_Hit(aIDX)
	Set LastSwitch = aSwitches(aIDX)
End Sub

'Walls don't have x/y coords so a spoof object is used for slingshots.
'Set LastSwitch = LeftSlingPos under 'Sub LeftSlingShot_SlingShot' 
Dim LeftSlingPos : Set LeftSlingPos = New WallSwitchPos
Dim RightSlingPos : Set RightSlingPos = New WallSwitchPos
Dim LeftLockPos : Set LeftLockPos = New WallSwitchPos

Class WallSwitchPos : Public x,y,name : End Class
'
LeftLockPos.Name = "LeftLock"
LeftLockPos.x = leftlock.x + 180
LeftLockPos.y = LeftLock.y


LeftSlingPos.Name = "LeftSlingShot"
LeftSlingPos.X = 160+25
LeftSlingPos.Y = 1480

RightSlingPos.Name = "RightSlingShot"
RightSlingPos.X = 700-25
RightSlingPos.Y = 1480

'End Floating text
'*************
```

Example helpers to get the correct location

```vbscript
Sub sw10_hit()
	Set LastSwitch = L44	'floatingtext
	'...
End Sub

Sub LeftSlingShot_Slingshot
	Set LastSwitch = LeftSlingPos	'floatingtext
	'...
End Sub
```

## TODO

* Explain how to add this to non-rom based tables.
* Switch to using the NVRAM callback instead of polling the NVRAM.
* Creating some kind of table patcher in vpxtool to automate this process.
