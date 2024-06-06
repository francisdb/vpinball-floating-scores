# vpinball-floating-scores
Instructions on how to apply floating scores to a Visual Pinball table.

## Acknowledgements

The floating scores script was extracted from [Space Station (Wiliams 1987)](https://www.vpforums.org/index.php?app=downloads&showfile=12717) by nFozzy. Implementation of [Toxie's idea](http://www.vpforums.org/index.php?showtopic=39255).

## Resources

## Table script

Keep in mind that not everybody likes these floating scores so make sure the user can disable it. On the original table they were only enabled for desktop mode:

```vbscript
Dim FloatingScores
FloatingScores = Table1.ShowDT 'Enable/Disable floating text scores  (Default: Table1.ShowDT)
'Does NOT play nicely with B2S at the moment.
'(In a multiplayer game, floating text will only appear for player 1)
```

Currently the system is set up for rom-based tables obly. It's also requesting the full NVRAM instead of looking at changes.
To make this work you need to add `UseVPMNVRAM = true` to the table script (place before LoadVPM, or otherwise calling core.vbs)
After that you can request the NVRAM with `Controller.NVRAM`

To make changed content of NVRAM available create a `Sub NVRAMCallback` (requires VPM 2.7 or newer)
The callback will receive an `Array` that contains the changes as an `Array(location, new value, old value)`

For Sys 11 the current score is located at the range `&h200` - `&h203`.

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

### Floating Text Class

```vbscript
'Floating Text Class 0.01a by nFozzy

'--Setup--
'Sprites(idx)	- Input Array of flasher objects. Overfilled text will be cut off. 
'(Please add this first, and only add indexes sequentially. The more arrays indexed, the more text frames can be displayed)

'Size (Public)  - Adjusts the type spacing. (Default 30)
'RotX (Property)- Adjust RotX. 
'FadeSpeedUp 	- Adjust scrolling speed

'--Methods--
'TextAt	(Sub)	- Input String, X coord, Y Coord. Primary method. Displays text at this coordinate.

'---Fading updates--
'Update2 - Handles all fading. REQUIRES SCRIPT FRAMETIME CALCULATION!


Class FloatingText
	Private Count, Prfx
	public Size
	Public Frame, Text, lock, loaded, lvl, z 'arrays
	Public FadeSpeedUp

	Private Sub Class_Initialize 
		Redim Frame(0), Text(0), lock(0), loaded(0), lvl(0), z(0)
		FadeSpeedUp = 1/1500 
		lvl(0) = 0 : loaded(0) = 1
		Count = 0 : size = 30
	end sub

	Public Property Let RotX(aInput) 
		'dim debugstr
		dim tmp, x, xx : for each x in Frame 
			tmp = x
			if IsArray(tmp) then 
				for each xx in tmp
					xx.RotX = aInput
					'debugstr = debugstr & xx.name & ".rotX = " & aInput & "..." & vbnewline
				next
			Else
				'debugstr = debugstr & "...not any array..." & vbnewline
			end If
		Next
		'if tb.text <> debugstr then tb.text = debugstr
	End Property

	Public Property Let Sprites(aIdx, aArray)
		if IsArray(aArray) Then
			Count = aIdx
			Redim Preserve Frame(aIdx)
			Redim Preserve Text(aIdx)
			Redim Preserve lock(aIdx)
			Redim Preserve loaded(aIdx)
			Redim Preserve lvl(aIdx)
			Redim Preserve z(aIdx)
			
			Lvl(aIdx) = 0 : Loaded(aIDX) = 1
			Frame(aIDX) = aArray	'Char contains sprites in 1d array. Use local variables to access sprites.
			z(aIDX) = aArray(0).height
			'msgbox "assigning " & aidx & vbnewline & ubound(mask)
		Else
			msgbox "FloatingText Error, 'Sprites' must be an array!"
		End If

	End Property

	Public Property Get Sprites(aIDX) : Sprites = Frame(aIDX) : End Property

	Public Property Let Prefix(aStr) : Prfx = aStr : End Property
	Public Property Get Prefix : Prefix = prfx : End Property

	Private Function MaxIDX(byval aArray, byref index)	'max, but also returns Index number of highest
		dim idx, MaxItem', str
		for idx = 0 to uBound(aArray)
			if IsEmpty(MaxItem) then 
				if not IsEmpty(aArray(idx)) then 
					MaxItem = aArray(idx)
					index = idx
				end If
			end if
			if not IsEmpty(aArray(idx) ) then 
				If aArray(idx) > MaxItem then MaxItem = aArray(idx) : index = idx
			end If
		Next
		MaxIDX = MaxItem
	End Function 

	Public Sub TextAt(aStr, aX, aY)		'Position text
		dim idx, xx, tmp

		'Choose a frame to assign
		dim ChosenFrame 
		'Find the highest value in Lvl and return it as ChosenFrame
		Call MaxIDX(Lvl, ChosenFrame)

		'Update Position
		'0 '1 '2
		'a(0) = aX
		'a(1) = aX + Size * index
		Text(ChosenFrame) = aStr 
		tmp = Frame(ChosenFrame)		' tmp = Sprite array contained by char array
		for xx = 0 to uBound(tmp)
			tmp(xx).x = aX + (Size * xx) - (Len(aStr)*Size)/2	'len part centers text 
			tmp(xx).y = aY
		Next'

		'Update Text
		for idx = 0 to uBound(tmp)
			xx = Mid(aStr, idx+1, 1)
			if xx <> "" then
				tmp(idx).visible = True
				tmp(idx).ImageA = Prfx & xx
				tmp(idx).ImageB = ""
			Else
				tmp(idx).visible = False
			end If
		Next
		If TypeName(aStr) <> "String" then FormatNumbers aStr, tmp
	
		'start fading / floating up
		lock(ChosenFrame) = False : Loaded(chosenframe) = False : lvl(chosenframe) = 0
	End Sub

	Private Sub FormatNumbers(aStr, aArray)
		If Len(aStr) >12 then Commalate len(aStr)-12,aArray
		If Len(aStr) > 9 then Commalate len(aStr)-9, aArray
		If Len(aStr) > 6 then Commalate len(aStr)-6, aArray
		If Len(aStr) > 3 Then Commalate len(aStr)-3, aArray
	End Sub
		
	Private Sub Commalate(aIDX, aArray)
		if aIdx-1 > uBound(aArray) then Exit Sub
		aArray(aIdx-1).ImageB = Prfx & "Comma"
	End Sub

	Public Sub Update2()	 'Both updates on -1 timer (Lowest latency, but less accurate fading at 60fps vsync)
		dim x : for x = 0 to Count
			if not Lock(x) then
				Lvl(x) = Lvl(x) + FadeSpeedUp * lampz.frametime	'TODO this requires frametime
				if Lvl(x) >= 1 then Lvl(x) = 1 : Lock(x) = True
			end if
		next
		Update
	End Sub

	Private Sub Update()	'Handle object updates
		dim x : for x = 0 to Count
			if not Loaded(x) then
				dim opacitycurve	'TODO section this off and make it a function or something
				if lvl(x) > 0.5 then 
					opacitycurve = pSlope(lvl(x), 0, 1, 1, 0)
				Else
					opacitycurve = 1
				end If

				dim xx
				for each xx in Frame(x)
					xx.height = z(x) + (lvl(x) * 100) 
					xx.IntensityScale = opacitycurve
				Next
				If Lock(x) Then
					if Lvl(x) = 1 then Loaded(x) = True	'finished fading
				end if
			end if
		next
	End Sub

End Class
```

### Keyframe Animation Class

```vbscript
'Keyframe Animation Class

'Setup
'.Update1 - update logic. Use 1 interval
'.Update - update objects. recommended -1 interval
'.Update2 - TODO alternative, updates both on -1 TODO

'Properties
'.State - returns if animation state (true or False)
'.Addpoint - Add keyframes. 3 argument sub : Keyframe#, Time Value, Output Value. Keep keyframes sequential, and timeline straight.
'.Modpoint - Modify an existing point
'.Debug - display debug animation (set before .addpoint to get full debug info)
'.Play - Play Animation
'.Pause - Pause mid-animation
'.Callback - string. Sub to call when animation is updated, with one argument sending the interpolated animation info

'Events
'.Callback(argument) - whatever you set callback to. Manually attach animation to this value - ie Showframe, Height, RotX, RotY, whatever...

Class cAnimation
	Public DebugOn
	Private KeyTemp(99,1)
	Private Lock, Loaded, StopAnim, UpdateSub
	Private ms, lvl, KeyStep, KeyLVL 'make these private later
	private LoopAnim

	Private Sub Class_Initialize : redim KeyStep(99) : redim KeyLVL(99) : Lock = True : Loaded = True : ms = 0: End Sub

	Public Property Get State : State = not Lock : End Property
	Public Property Let CallBack(String) : UpdateSub = String : End Property

	public Sub AddPoint(aKey, aMS, aLVL)
		KeyTemp(aKey, 0) = aMS : KeyTemp(aKey, 1) = aLVL
		Shuffle aKey
	End Sub

	'  v  v   v    keyframes IDX / (0)
	'	  .
	'	 / \lvl (1)
	'___/	 \___
	'-----MS--------->

	'in -> AddPoint(KeyFrame#, 0) = KeyFrame(Time) 
	'in -> AddPoint(KeyFrame#, 1) = KeyFrame(LVL) 
	'	(1d array conversion)
	'into -> KeyStep(99)
	'into -> KeyLvl(99)
	Private Sub Shuffle(aKey) 'shuffle down keyframe data into 1d arrays 'this sucks, it does't actually shuffle anything
		redim preserve KeyStep(99) : redim preserve KeyLvl(99)
		dim str : str = "shuffling @ " & akey & vbnewline
		dim x : for x = 0 to uBound(KeyTemp)
			if KeyTemp(x,0) <> "" Then
				KeyStep(x) = KeyTemp(x,0) : KeyLvl(x) = KeyTemp(x,1)
			Else
				if x = 0 then msgbox "cAnimation error: Please start at keyframe 0!" : exit Sub
				redim preserve KeyStep(x-1) : redim preserve KeyLvl(x-1) : Exit For
			end If
		Next
		str = str & "uBound step:" & uBound(keystep) & vbnewline & "uBound KeyLvl:" & uBound(KeyLvl) & vbnewline
		If DebugOn then TBanima.text = str & "printing steps:" & vbnewline & PrintArray(keystep) & vbnewline & "printing step values:" & vbnewline & PrintArray(keylvl)
	End Sub

	Private function PrintArray(aArray)	'debug
		dim str, x : for x = 0 to uBound(aArray) : str = str & x & ":" & aArray(x) & vbnewline : Next : printarray = str
	end Function

	Public Sub ModPoint(idx, aMs, aLvl) : KeyStep(idx) = aMs : KeyLVL(idx) = aLvl : End Sub  'modify a point after it's set

	Public Sub Play()	: StopAnim = False : Lock = False : Loaded = False : LoopAnim = False :  End Sub 'play animation
	Public Sub PlayLoop()	: StopAnim = False : Lock = False : Loaded = False : LoopAnim = True: End Sub 'play animation
	Public Sub Pause()	: StopAnim = True : end Sub	'pause animation


	Public Sub Update2()	 'Both updates on -1 timer (Lowest latency, but less accurate fading at 60fps vsync)
		'FrameTime = gametime - InitFrame : InitFrame = GameTime	'Calculate frametime
		if not lock then
			if ms > keystep(uBound(keystep)) then 
				If LoopAnim then ms = 0 else StopAnim = True : ms = 0	'No looping
			End If
			if StopAnim then Lock = True	'if stopped by script or by end of animation
			if Not Lock Then ms = ms + 1*lampz.FrameTime : lvl = LinearEnvelope(ms, KeyStep, KeyLVL)
		end if
		Update
	End Sub

	Public Sub Update1()	'update logic
		if not lock then
			if ms > keystep(uBound(keystep)) then 
				If LoopAnim then ms = 0 else StopAnim = True : ms = 0	'No looping
			End If
			if StopAnim then Lock = True	'if stopped by script or by end of animation
			if Not Lock Then ms = ms + 1 : lvl = LinearEnvelope(ms, KeyStep, KeyLVL)
		end if
	End Sub

	Public Sub Update() 	'Update object
		if Not Loaded then
			if Lock then Loaded = True
			if DebugOn then dim str : str = "ms:" & ms & vbnewline & "lvl:" & lvl & vbnewline & _
									Lock & " " & loaded & vbnewline :	tbanim.text = str
			proc UpdateSub, lvl
		end if
	End Sub

End Class 
```
