local Translations = {
    error = {
        ["cancled"] = "Canceled",
        ["no_plane"] = "You have no plane!",
        ["not_enough"] = "Not Enough Money (%{value} required)",
        ["too_far"] = "You are too far away from the drop-off point",
        ["early_finish"] = "Due to early finish (Completed: %{completed} Total: %{total}), your deposit will not be returned.",
        ["never_clocked_on"] = "You never clocked on!",
        ["all_occupied"] = "All parking spots are occupied",
        ["job"] = "You must get the job from the job center",
    },
    success = {
        ["clear_routes"] = "Cleared users routes they had %{value} routes stored",
        ["pay_slip"] = "You got $%{total}, your payslip %{deposit} got paid to your bank account!",
    },
    target = {
        ["talk"] = 'Talk to TSA',
        ["grab_luggage"] = "Grab luggage bag",
        ["load_luggage"] = "Load luggage onto plane",
    },
    menu = {
        ["header"] = "ATC Main Menu",
        ["collect"] = "Collect Paycheck",
        ["return_collect"] = "Return plane and collect paycheck here!",
        ["route"] = "Request Route",
        ["request_route"] = "Request a NAV 1 Route",
    },
    info = {
        ["payslip_collect"] = "[E] - Payslip",
        ["payslip"] = "Payslip",
        ["not_enough"] = "You have not enough money for the deposit.. Deposit costs are $%{value}",
        ["deposit_paid"] = "You have paid $%{value} deposit!",
        ["no_deposit"] = "You have no deposit paid on this vehicle..",
        ["plane_returned"] = "Plane returned, collect your payslip to receive your pay and deposit back!",
        ["luggage_left"] = "There are still %{value} luggage left!",
        ["luggage_still"] = "There is still %{value} luggage over there!",
        ["all_luggage"] = "All luggage bags are done, proceed to the next location!",
        ["hangar_issue"] = "There was an issue at the hangar, please return immediately!",
        ["done_working"] = "You are done working! Go back to the hangar.",
        ["started"] = "You have started working, location marked on GPS!",
        ["grab_luggage"] = "[E] Grab a luggage",
        ["stand_grab_luggage"] = "Stand here to grab a luggage.",
        ["load_luggage"] = "[E] Load luggage",
        ["progressbar"] = "Loading onto plane..",
        ["luggage_in_plane"] = "Put the luggage in your plane..",
        ["stand_here"] = "Stand here..",
        ["payout_deposit"] = "(+ $%{value} deposit)",
        ["store_plane"] =  "[E] - Store Airplane",
        ["get_plane"] =  "[E] - Airplane",
        ["picking_luggage"] = "Grabbing luggage..",
        ["talk"] = "[E] Talk to Talk to TSA",
    },
}

Lang = Lang or Locale:new({
    phrases = Translations,
    warnOnMissing = true
})