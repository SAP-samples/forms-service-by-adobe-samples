sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'com/sap/fp/demo/cinema/test/integration/FirstJourney',
		'com/sap/fp/demo/cinema/test/integration/pages/TicketMain'
    ],
    function(JourneyRunner, opaJourney, TicketMain) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('com/sap/fp/demo/cinema') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheTicketMain: TicketMain
                }
            },
            opaJourney.run
        );
    }
);