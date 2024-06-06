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
