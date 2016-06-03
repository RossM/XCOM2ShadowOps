interface XMBOverrideInterface;

function class GetOverrideBaseClass();
function GetOverrideVersion(out int Major, out int Minor, out int Patch);

function bool GetExtObjectValue(name Type, out object Value, optional object Data1 = none, optional object Data2 = none);
function SetExtObjectValue(name Type, object Value, optional object Data1 = none, optional object Data2 = none);
function bool GetExtFloatValue(name Type, out float Value, optional object Data1 = none, optional object Data2 = none);
function SetExtFloatValue(name Type, float Value, optional object Data1 = none, optional object Data2 = none);
function bool GetExtStringValue(name Type, out string Value, optional object Data1 = none, optional object Data2 = none);
function SetExtStringValue(name Type, string Value, optional object Data1 = none, optional object Data2 = none);