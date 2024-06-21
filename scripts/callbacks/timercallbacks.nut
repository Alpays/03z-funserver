/*
 * Just4Fun Vice City: Multiplayer (VC:MP) 0.3z R2 server
 * Authors: sfwidde ([R3V]Kelvin) and [VU]Alpays
 * 2024-06-20
 */

function TimerCallback_DisplayNewsreelMessage()
{
	// Does newsreel need to be rewound?
	if (newsreelIndex > (newsreelTexts.len() - 1))
	{
		newsreelIndex = 0;
	}

	InfoMessage(newsreelTexts[newsreelIndex++]);
}
