class UIScreenListener_Generic extends UIScreenListener;

var bool bInited;

event OnInit(UIScreen Screen)
{
	if (bInited)
		return;
	bInited = true;

	class'X2DownloadableContentInfo_ShadowOps_LW2'.static.OnPostTemplatesCreated();
}