public class leftmove{
	public static void main(String[] args) {
		int num=Integer.valueOf(args[0]);
		int i=Integer.valueOf(args[1]);
		System.out.println("ANS="+(num>>>i));
	}
}