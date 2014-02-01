public class Temp{

    public static double getTemp(int binary){
        return (binary/1023.0)*5.0/(20000.0/47.0)/(41.0/1000000);
    }
    
    public static void printTemp(){
        for(int k = 0; k < 1024; k++){
            if(k%200 == 0){
                System.out.printf("\n DW ");
            }
            else{
                System.out.printf(", ");
            }
            System.out.printf("%03.0f", getTemp(k));
        }
    }

}