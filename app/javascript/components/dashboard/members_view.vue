<template>
  <div id="members">   
       <div class="container mt-4">
      <button @click="download" 
      id="printBtn" 
      class="btn btn-sm btn-outline-dark mt-1 mr-1 mb-1"
      style="font-size:.70rem" >EXPORT TO PDF</button>
       <button @click="tableToExcel('table', 'Team Members')"
       class="btn btn-sm btn-outline-dark m-1"
      style="font-size:.70rem"
      >EXPORT TO EXCEL</button>         
      <div class="table-responsive-md">
        <table class="table table-sm table-bordered" ref="table" id="teamMembersList">        
          <thead>
            <tr>
              <th></th>
              <th>Name</th>
              <th>Position</th>
              <th>Organization</th>
              <th>Email</th>
              <th>Phone</th>             
            </tr>
          </thead>
          <tbody>
            <tr v-for="(user, i) in orderedUsers"  v-if="(user.status) === 'active'" :load="log(user)">        
              <td class="text-center">{{i+1}}</td>
              <td>{{user.fullName}}</td>
              <td>{{user.title}}</td>
              <td>{{user.organization}}</td>
              <td><a :href="`mailto:${user.email}`">{{user.email}}</a></td>
              <td><a :href="`tel:${user.phoneNumber}`">{{user.phoneNumber}}</a></td>            
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
  import {mapGetters, mapActions} from 'vuex';
  import  {jsPDF} from "jspdf";
  import 'jspdf-autotable';
  export default {
    name: "TeamMembersView",
    data(){
    return{
      uri :'data:application/vnd.ms-excel;base64,',
      template:'<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="https://www.w3.org/TR/2018/SPSD-html401-20180327/"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>',
      base64: function(s){ return window.btoa(unescape(encodeURIComponent(s))) },
      format: function(s, c) { return s.replace(/{(\w+)}/g, function(m, p) { return c[p]; }) }
    }
    },
    
    methods: {      
      //download method for PDF
      //tableToExcel method for excel
      download(){
        const doc = new jsPDF("l")
        const html = this.$refs.table.innerHTML
       doc.autoTable({ html: '#teamMembersList' })
       doc.save("Team_Members_list.pdf")
      },
       log(user) {
        console.log(user)
      },
      tableToExcel(table, name){      
      if (!table.nodeType) table = this.$refs.table
      var ctx = {worksheet: name || 'Worksheet', table: table.innerHTML}
      window.location.href = this.uri + this.base64(this.format(this.template, ctx))
        }
    },    
    computed: {
      ...mapGetters([
        'projectUsers'
      ]),
      orderedUsers: function() {
        // if (this.projectUsers.status == active) {
        return _.orderBy(this.projectUsers, 'lastName', 'asc')
        // }
      }
    }
  }
</script>

<style lang="scss">
</style>
