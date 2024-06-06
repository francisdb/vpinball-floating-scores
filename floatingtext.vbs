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