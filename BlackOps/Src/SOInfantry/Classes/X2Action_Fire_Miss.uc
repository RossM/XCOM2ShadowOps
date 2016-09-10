//-----------------------------------------------------------
// Used by the visualizer system to control a Visualization Actor
//-----------------------------------------------------------
class X2Action_Fire_Miss extends X2Action_Fire;

function Init(const out VisualizationTrack InTrack)
{
	local string MissAnimString;
	local name MissAnimName;
	local int LastCharacter;

	super.Init(InTrack);

	// Always treat as miss. If miss, remove A, append MissA. Only orverwrite if can play.
	MissAnimString = string(AnimParams.AnimName);
	LastCharacter = Asc(Right(MissAnimString, 1));
		
	// Jwats: Only remove the A-Z if it is there, otherwise leave it the same
	if( LastCharacter >= 65 && LastCharacter <= 90 )
	{
		MissAnimString = Mid(MissAnimString, 0, (Len(MissAnimString) - 1));
	}
		
	MissAnimString $= "Miss";
	MissAnimName = name(MissAnimString);

	if( UnitPawn.GetAnimTreeController().CanPlayAnimation(MissAnimName) )
	{
		AnimParams.AnimName = MissAnimName;
	}
}
