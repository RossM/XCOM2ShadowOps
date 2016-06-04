interface XMBOverrideInterface;

function class GetOverrideBaseClass();
function GetOverrideVersion(out int Major, out int Minor, out int Patch);

function bool GetExtValue(LWTuple Data);
function bool SetExtValue(LWTuple Data);
