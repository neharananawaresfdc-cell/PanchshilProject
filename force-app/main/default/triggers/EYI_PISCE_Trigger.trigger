trigger EYI_PISCE_Trigger on ProcessInstanceStepChangeEvent (after insert) {
 System.debug(JSON.serializepretty(trigger.new));
}