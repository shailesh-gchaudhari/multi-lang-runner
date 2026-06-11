/**
 * Stats.java - Finds max, min, and average of a list of 10 numbers.
 */
public class Stats {
    public static void main(String[] args) {
        int[] numbers = {42, 17, 85, 3, 96, 54, 28, 71, 9, 63};

        int highest = numbers[0];
        int lowest  = numbers[0];
        double sum  = 0;

        for (int n : numbers) {
            if (n > highest) highest = n;
            if (n < lowest)  lowest  = n;
            sum += n;
        }

        double average = sum / numbers.length;

        System.out.println("========================================");
        System.out.println("         JAVA STATS PROGRAM");
        System.out.println("========================================");
        System.out.print("Numbers  : [");
        for (int i = 0; i < numbers.length; i++) {
            System.out.print(numbers[i] + (i < numbers.length - 1 ? ", " : ""));
        }
        System.out.println("]");
        System.out.println("Highest  : " + highest);
        System.out.println("Lowest   : " + lowest);
        System.out.printf( "Average  : %.2f%n", average);
        System.out.println("========================================");
    }
}
