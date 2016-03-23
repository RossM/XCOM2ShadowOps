class UIPersonnel_SoldierListItem_BO extends UIPersonnel_SoldierListItem;

// Modified to display subclass name
simulated function UpdateData()
{
	local XComGameState_Unit Unit;
	local string UnitLoc, status, statusTimeLabel, statusTimeValue, classIcon, rankIcon, flagIcon;	
	local int iRank;
	local X2SoldierClassTemplate SoldierClass;
	
	Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitRef.ObjectID));

	iRank = Unit.GetRank();

	SoldierClass = Unit.GetSoldierClassTemplate();

	class'UIUtilities_Strategy'.static.GetPersonnelStatusSeparate(Unit, status, statusTimeLabel, statusTimeValue);
	if( statusTimeValue == "" )
		statusTimeValue = "---";

	flagIcon = Unit.GetCountryTemplate().FlagImage;
	rankIcon = class'UIUtilities_Image'.static.GetRankIcon(iRank, SoldierClass.DataName);
	classIcon = SoldierClass.IconImage;

	// if personnel is not staffed, don't show location
	if( class'UIUtilities_Strategy'.static.DisplayLocation(Unit) )
		UnitLoc = class'UIUtilities_Strategy'.static.GetPersonnelLocation(Unit);
	else
		UnitLoc = "";

	AS_UpdateDataSoldier(Caps(Unit.GetName(eNameType_Full)),
					Caps(Unit.GetName(eNameType_Nick)),
					Caps(`GET_RANK_ABBRV(Unit.GetRank(), SoldierClass.DataName)),
					rankIcon,
					Caps(SoldierClass != None ? Unit.GetSoldierClassDisplayName() : ""),
					classIcon,
					status,
					statusTimeValue $"\n" $ Class'UIUtilities_Text'.static.CapsCheckForGermanScharfesS(Class'UIUtilities_Text'.static.GetSizedText( statusTimeLabel, 12)),
					UnitLoc,
					flagIcon,
					false, //todo: is disabled 
					Unit.ShowPromoteIcon(),
					false); // psi soldiers can't rank up via missions
}
