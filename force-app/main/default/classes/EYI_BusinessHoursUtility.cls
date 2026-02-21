/**
 * @description       : 
 * @author            : Digambar Ganage
 * @group             : EY Notification Framework
 * @last modified on  : 11-18-2024
 * @last modified by  : Digambar Ganage 
**/
public with sharing class EYI_BusinessHoursUtility {
    private List<Boolean> businessDay = new Boolean[7];
    private List<Time> startHours = new Time [7];
    private List<Time> endHours = new Time [7];
    private Date knownSunday = date.newInstance(2013, 1, 6);
    private static Time START_TIME;
    private static Time END_TIME;
    // Constructor creates businessDay array
    public EYI_BusinessHoursUtility() {
   
        BusinessHours bh =
        [SELECT
            SundayStartTime, MondayStartTime, TuesdayStartTime,
            WednesdayStartTime, ThursdayStartTime, FridayStartTime,
            SaturdayStartTime, SundayEndTime, MondayEndTime,TuesdayEndTime,
            WednesdayEndTime, ThursdayEndTime, FridayEndTime,SaturdayEndTime
        FROM BusinessHours 
        WHERE Name = :Label.EYI_Business_Hours_Name];
    
        businessDay[0] = (bh.SundayStartTime != null);
        businessDay[1] = (bh.MondayStartTime != null);
        businessDay[2] = (bh.TuesdayStartTime != null);
        businessDay[3] = (bh.WednesdayStartTime != null);
        businessDay[4] = (bh.ThursdayStartTime != null);
        businessDay[5] = (bh.FridayStartTime != null);
        businessDay[6] = (bh.SaturdayStartTime != null);
        
        startHours[0] = bh.SundayStartTime;
        startHours[1] = bh.MondayStartTime;
        startHours[2] = bh.TuesdayStartTime;
        startHours[3] = bh.WednesdayStartTime;
        startHours[4] = bh.ThursdayStartTime;
        startHours[5] = bh.FridayStartTime;
        startHours[6] = bh.SaturdayStartTime;
    
        endHours[0] = bh.SundayEndTime;
        endHours[1] = bh.MondayEndTime;
        endHours[2] = bh.TuesdayEndTime;
        endHours[3] = bh.WednesdayEndTime;
        endHours[4] = bh.ThursdayEndTime;
        endHours[5] = bh.FridayEndTime;
        endHours[6] = bh.SaturdayEndTime;
    
    }
    // Check if today is a business day
    public Boolean isBusinessDay(Date inputDate) {
        // index i is index into the businessDay array based on inputDate
        Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
        return (businessDay[i]);
    }
    // Get the start time
    public Time getStartTime(Date inputDate) {
        Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
        return (startHours[i]);
    }
    // Get the End time
    public Time getEndTime(Date inputDate) {
        Integer i = Math.mod(Math.abs(this.knownSunday.daysBetween(inputDate)),7);
        return (endHours[i]);
    }
    // Helper method to check if the current datetime is within business hours
    private static Boolean isWithinBusinessHours(Datetime nextdatetime) {
        Time currentTime = nextdatetime.time();
        System.debug(' In if END_TIME==>'+START_TIME);
        System.debug(' In if END_TIME==>'+END_TIME);
        System.debug(' In if END_TIME ==>'+currentTime);

        return currentTime >= START_TIME && currentTime <= END_TIME;
    }
    //Get future time of added hrs 
    public Datetime addBusinessHours(Datetime currentDatetime, Integer hoursToAdd) {
        Integer minutes = hoursToAdd * 60;
        Datetime dt = addBusinessMinutes(currentDatetime , minutes);
        return dt;
    }
    //Get future time of added Minutes 
    public static Datetime addBusinessMinutes(Datetime currentDatetime, Integer minutesToAdd) {
        EYI_BusinessHoursUtility bds = new EYI_BusinessHoursUtility();
        START_TIME = bds.getStartTime(System.now().date());
        END_TIME = bds.getEndTime(System.now().date());
        // Start with the current datetime
        Integer totalMinutesToAdd = minutesToAdd;
        Datetime newDatetime = currentDatetime;
        // Check if the current time is within business hours
        if (isWithinBusinessHours(newDatetime)) {
            Integer remainingMinutesInDay = getRemainingMinutesInDay(newDatetime);
            // Case 1: If the minutes to add stay within the current business day
            if (totalMinutesToAdd <= remainingMinutesInDay) {
                System.debug(' In if ==>');

                System.debug(' totalMinutesToAdd==>'+totalMinutesToAdd);
                System.debug(' remainingMinutesInDay==>'+remainingMinutesInDay);

                newDatetime = addMinutesToDatetime(newDatetime, totalMinutesToAdd);
                return newDatetime;
            } else {
                System.debug(' In 2nd  Last Else==>');

                System.debug(' totalMinutesToAdd==>'+totalMinutesToAdd);
                System.debug(' remainingMinutesInDay==>'+remainingMinutesInDay);
                // Case 2: If the minutes to add exceed today's business hours
                totalMinutesToAdd -= remainingMinutesInDay;
                newDatetime = getNextBusinessDayStart(newDatetime);
            }
        } else {
            // Case 3: If the current time is outside of business hours, move to the next business day
            newDatetime = getNextBusinessDayStart(newDatetime);
            System.debug(' In Last Else==>');

            System.debug(' totalMinutesToAdd==>'+totalMinutesToAdd);
        }
        // Loop through business days until all minutes are added
        while (totalMinutesToAdd > 0) {
            Integer minutesInCurrentBusinessDay = getRemainingMinutesInDay(newDatetime);
            
            if (totalMinutesToAdd <= minutesInCurrentBusinessDay) {
                newDatetime = addMinutesToDatetime(newDatetime, totalMinutesToAdd);
                totalMinutesToAdd = 0;
            } else {
                totalMinutesToAdd -= minutesInCurrentBusinessDay;
                newDatetime = getNextBusinessDayStart(newDatetime);
            }
        }
        return newDatetime;
    }
    private static Integer getRemainingMinutesInDay(Datetime nextdatetime) {
        Time currentTime = nextdatetime.time();
        Integer currentMinutes = currentTime.hour() * 60 + currentTime.minute();
        Integer endMinutes = END_TIME.hour() * 60 + END_TIME.minute();
        System.debug(' END_TIME.hour()===>'+END_TIME.hour() +' END_TIME.hour()===>'+END_TIME.minute());
        System.debug(' endMinutes==>'+endMinutes +'currentMinutes===>'+currentMinutes);

        return endMinutes - currentMinutes;
    }
    
    // Helper method to add minutes to the datetime
    private static Datetime addMinutesToDatetime(Datetime nextdatetime, Integer minutesToAdd) {
        System.debug('nextdatetime.addMinutes(minutesToAdd) ==> '+nextdatetime.addMinutes(minutesToAdd));
        return nextdatetime.addMinutes(minutesToAdd);
    }

    // Helper method to get the start of the next business day (9:30 AM)
    private static Datetime getNextBusinessDayStart(Datetime currentDatetime) {
        Date nextBusinessDay = getNextBusinessDay(currentDatetime.date());
        return Datetime.newInstance(nextBusinessDay, START_TIME);
    }

    // Helper method to get the next business day, skipping weekends
    private static Date getNextBusinessDay(Date currentDate) {
        EYI_BusinessHoursUtility bds = new EYI_BusinessHoursUtility();
        Date nextBusinessDay = currentDate;
        Integer i = 0;
        do {
            nextBusinessDay = nextBusinessDay.addDays(1);
            i++;
        } while (!bds.businessDay[Math.mod(i, 7)]); // Skip if not a business day (Monday to Friday)
        return nextBusinessDay;
    }
    
    // Helper method to get the start of the next business day (9:30 AM)
    public static long getBuinessDaysDiffInHrs(Datetime startDatetime,Datetime endDatetime) {
        long diffinms = 0; 
        long hrs=0;
        BusinessHours bh = [SELECT Id
                            FROM BusinessHours 
                            WHERE Name = :Label.EYI_Business_Hours_Name];
        diffinms = BusinessHours.diff(bh.id,startDatetime,endDatetime);
        System.debug(' getBuinessDiffHrs diffinms===>'+diffinms);

        hrs = diffinms / 3600000;
        System.debug('hrs===>'+hrs);
        return hrs;
    }
    // Helper method to get the start of the next business day (9:30 AM)
    public static long getBuinessDaysDiffInDays(Datetime startDatetime,Datetime endDatetime) {
        long diffinms = 0; 
        long days = 0;
        BusinessHours bh = [SELECT Id
                            FROM BusinessHours 
                            WHERE Name = :Label.EYI_Business_Hours_Name];
        diffinms = BusinessHours.diff(bh.id,startDatetime,endDatetime);
        System.debug('getBuinessDiffDays diffinms===>'+diffinms);

        days = diffinms /  86400000;
        System.debug('days===>'+days);
        return days;
    }
    public static Integer getDateDiffInDays(Datetime startDatetime, Datetime endDatetime) {
        System.debug('startDatetime diffinms ===> ' + startDatetime);
        System.debug('endDatetime diffinms ===> ' + endDatetime);
        // Calculate the difference in milliseconds
        //long diffinms = endDatetime.getTime() - startDatetime.getTime();
        //System.debug('getDateDiffInDays diffinms ===> ' + diffinms);
        //Double diffinms = endDatetime- startDatetime;
        Integer noOfDays = startDatetime.date().daysBetween(endDatetime.date());
        // Convert milliseconds to days
        //long days = diffinms / (1000 * 60 * 60 );  // Number of milliseconds in a day (1000 ms * 60 sec * 60 min * 24 hours)
    
        return noOfDays;
    }
    

}