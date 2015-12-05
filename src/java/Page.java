public class Page{
	double weight={0.333,0.5,1,0.5};
	int adj={{0,0,1,1},{1,0,0,0},{1,1,0,1},{1,1,0,0}};
	double nodeVal={0.15/4,0.15/4,0.15/4,0.15/4}
	public void multi(int time){
		for(int i=0;i<nodeVal.length;i++){	
			for(int j=0;j<nodeVal[0].length;j++){
				nodeVal[i]=0.15/4+(1-0.15)*(nodeVal[i][j]);			
			}	

		}
	}





	public void print(int[][] adjacency){
		for(int i=0;i<adjacency.length;i++){
			for(int j=0;j<adjacency[0].length;j++){
				System.out.print(" "+adjacency[i][j]+" ");
			}
			System.out.println();
		}
	}

	public void print(int [] adjacency){
		for(int i=0;i<adjacency.length;i++){
			System.out.println(adjacency[i]+" ");
		}
	}


}